import json
import boto3
import os
import uuid
import datetime
import io
import base64
import cgi
from botocore.exceptions import ClientError

def get_file_from_request_body(headers: dict, body):
    fp = io.BytesIO(base64.b64decode(body)) # decode
    environ = {"REQUEST_METHOD": "POST"}
    content_len = headers["content-length"] if "content-length" in headers else len(body)
    headers = {
        "content-type": headers["content-type"],
        "content-length": content_len,
    }

    fs = cgi.FieldStorage(fp=fp, environ=environ, headers=headers)

    return fs


def create_post(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    s3 = session.resource('s3')
    bucket_name = os.getenv("BUCKET_NAME")
    post_table = dynamodb.Table(os.getenv("POST_TABLE_NAME"))
    postid = str(uuid.uuid4())
    
    headers = {k.lower(): v for k, v in event["headers"].items()}
    form_data = get_file_from_request_body(
        headers=headers, body=event["body"]
    )
    
    data = {}
    image_files = []
    
    for key in form_data.keys():

        if form_data[key].filename: # file -> save
            image_key = f'images/{postid}-{form_data[key].name}'
            s3_obj = s3.Object(os.getenv("BUCKET_NAME"), image_key)
            s3_obj.put(Body=form_data[key].value, ContentType='image/jpeg',)
            image_url = f'https://{bucket_name}.s3.amazonaws.com/{image_key}'
            image_files.append(image_url)
            data['image_files'] = image_files
        else:
            value = form_data[key].value
            data[key] = value

    title = data['title']
    category = data['category']
    content = data['content']
    writerid = data['writerid']
    score = data['score']
    createdTime = datetime.datetime.now().isoformat()
    
    item = {
        'post_ID': postid,
        'title': title,
        'category': category,
        'content': content,
        'writerid': writerid,
        'score': score,
        'createdTime': createdTime,
        'image_files': image_files,
    }
    
    try:
        post_table.put_item(Item = item)
    except ClientError as e:
        return {
            "statusCode": 500,
            "body": json.dumps(e),
        }
    return {
        "statusCode" : 200,
        "body" : json.dumps(f'{title} created!'),
    }

def read_post(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    post_table = dynamodb.Table(os.getenv("POST_TABLE_NAME"))

    try:
        response = post_table.scan()
    except Exception as e:
        return {
            "statusCode" : 500,
            "body" : json.dumps('An error occurred while reading posts.'),
        }

    if 'Items' in response:
        items = response['Items']
        for item in items:
            item['score'] = float(item['score'])
        return {
            "statusCode" : 200,
            "body" : json.dumps(response['Items']),
        }
    else:
        return {
            "statusCode" : 404,
            "body" : json.dumps('post not found!'),
        }

def update_post(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    s3 = session.resource('s3')
    bucket_name = os.getenv("BUCKET_NAME")
    post_table = dynamodb.Table(os.getenv("POST_TABLE_NAME"))

    headers = {k.lower(): v for k, v in event["headers"].items()}
    form_data = get_file_from_request_body(
        headers=headers, body=event["body"]
    )

    data = {}
    image_files = []
    postid = form_data.getfirst("post_ID")
    for key in form_data.keys():
        # 기존 이미지 삭제
        if key == 'imagefiles' and form_data[key] != None:
            image_urls = form_data[key].value.split(',')
            for image_url in image_urls:
                file_key = image_url.split('/')[3] + '/' + image_url.split('/')[4]
                s3_obj = s3.Object(bucket_name, file_key)
                s3_obj.delete()
        # 새 이미지 삽입
        elif form_data[key].filename:
            image_key = f'images/{postid}-{form_data[key].name}'
            s3_obj = s3.Object(os.getenv("BUCKET_NAME"), image_key)
            s3_obj.put(Body=form_data[key].value, ContentType='image/jpeg',)
            image_url = f'https://{bucket_name}.s3.amazonaws.com/{image_key}'
            image_files.append(image_url)
            data['image_files'] = image_files
        else:
            value = form_data[key].value
            data[key] = value
    
    title = data['title']
    category = data['category']
    content = data['content']
    score = data['score']
    
    update_expression = 'SET title = :new_title, category = :new_category, content =:new_content, score =:new_score, image_files =:new_image_files'
    expression_attribute_values = {
        ':new_title': title,
        ':new_category': category,
        ':new_content': content,
        ':new_score': score,
        ':new_image_files': image_files,
    }
    
    try:
        response = post_table.update_item(
            Key = {
                'post_ID': postid,
            },
            UpdateExpression = update_expression,
            ExpressionAttributeValues = expression_attribute_values
        )
    except Exception as e:
        return {
            "statusCode" : 500,
            "body": json.dumps('An error occurred while updating the post.'),
        }

    return {
        "statusCode" : 200,
        "body" : json.dumps('post updated!'),
    }

def delete_post(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    s3 = session.client('s3')
    post_table = dynamodb.Table(os.getenv("POST_TABLE_NAME"))
    body = json.loads(event['body'])

    postid = body['post_ID']

    try:
        response = post_table.get_item(Key={'post_ID': postid})
        if 'Item' in response:
            item = response['Item']
            image_files = item.get('image_files', [])
            
        for image_url in image_files:
            file_key = image_url.split('/')[3] + '/' + image_url.split('/')[4]
            s3.delete_object(Bucket=os.getenv("BUCKET_NAME"), Key=file_key)
            
        response = post_table.delete_item(
            Key = {
                'post_ID' : postid,
            }
        )
    except Exception as e:
        return {
            "statusCode" : 500,
            "body": json.dumps('An error occurred while deleting the post.'),
        }
    return {
        "statusCode" : 200,
        "body" : json.dumps('post deleted!'),
    }

def lambda_handler(event, context):
    http_method = event['httpMethod']

    if http_method=='POST':
        return create_post(event,context)
    elif http_method == 'GET':
        return read_post(event, context)
    elif http_method == 'PATCH':
        return update_post(event, context)
    elif http_method =='DELETE':
        return delete_post(event, context)
    else:
        return {
            'statusCode':400,
            'body': json.dumps('Error')
        }