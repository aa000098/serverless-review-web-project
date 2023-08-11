import json
import boto3
import os
import uuid
import datetime
import io
from botocore.exceptions import ClientError
from email import message_from_bytes


def create_post(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    s3 = session.client('s3')
    bucket_name = os.getenv("BUCKET_NAME")
    post_table = dynamodb.Table(os.getenv("POST_TABLE_NAME"))
    postid = str(uuid.uuid4())
    
    content_type = event['headers']['content-type']
    boundary = content_type.split('; ')[1].split('=')[1]
    body = event['body'].strip()

    parts = body.split('--' + boundary)
    fields = {}
    image_files = []
    parts = parts[1:]
    for part in parts:
        if part.strip() == '--':
            break
        if 'filename' not in part:
            lines = part.strip().split('\r\n\r\n')
            field_name = lines[0].split('; ')[1].split('=')[1].strip('"')
            if 'category' in field_name:
                field_name = field_name.split('"')[0]
            field_value = lines[1]
            fields[field_name] = field_value
        else :
            lines = part.strip().split('\r\n\r\n')
            file_name = lines[0].split('; ')[1].split('=')[1].strip('"')
            content= lines[1]
            image_data = content.encode('utf-8')
            image_key = f'images/{postid}-{file_name}'
            
            s3.upload_fileobj(
                io.BytesIO(image_data),
                bucket_name,
                image_key,
                ExtraArgs={
                    'ContentType': 'image/jpeg',
                }
            )
            image_url = f'https://{bucket_name}.s3.amazonaws.com/{image_key}'
            image_files.append(image_url)

    title = fields['title']
    category = fields['category']
    content = fields['content']
    writerid = fields['writerid']
    score = fields['score']
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
    s3 = session.client('s3')
    bucket_name = os.getenv("BUCKET_NAME")
    post_table = dynamodb.Table(os.getenv("POST_TABLE_NAME"))

    # 이벤트 추출
    content_type = event['headers']['content-type']
    boundary = content_type.split('; ')[1].split('=')[1]
    body = event['body'].strip()
    
    parts = body.split('--' + boundary)
    fields = {}
    image_files = []
    parts = parts[1:]

    for part in parts:
        if part.strip() == '--':
            break
        if 'filename' not in part:
            lines = part.strip().split('\r\n\r\n')
            field_name = lines[0].split('; ')[1].split('=')[1].strip('"')
            if 'category' in field_name or 'imagefiles' in field_name:
                field_name = field_name.split('"')[0]
            if len(lines) > 1:
                field_value = lines[1]
            else:
                field_value = None
            fields[field_name] = field_value
            # 기존 이미지 삭제
            if field_name == 'imagefiles' and field_value != None:
                image_urls = field_value.split(',')
                for image_url in image_urls:
                    file_key = image_url.split('/')[3] + '/' + image_url.split('/')[4]
                    s3.delete_object(Bucket=bucket_name, Key=file_key)
                
        # 새 이미지 업로드
        else :
            postid = fields['post_ID']
            lines = part.strip().split('\r\n\r\n')
            file_name = lines[0].split('; ')[1].split('=')[1].strip('"')
            content= lines[1]
            
            image_data = content.encode('utf-8')
            image_key = f'images/{postid}-{file_name}'

            s3.upload_fileobj(
                io.BytesIO(image_data),
                bucket_name,
                image_key,
                ExtraArgs={
                    'ContentType': 'image/jpeg',
                }
            )
            image_url = f'https://{bucket_name}.s3.amazonaws.com/{image_key}'
            image_files.append(image_url)
    
    postid = fields['post_ID']
    title = fields['title']
    category = fields['category']
    content = fields['content']
    score = fields['score']
    
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