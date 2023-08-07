import json
import boto3
import os
import uuid
import datetime
from botocore.exceptions import ClientError


def create_post(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    post_table = dynamodb.Table(os.getenv("POST_TABLE_NAME"))
    body = json.loads(event['body'])

    postid = str(uuid.uuid4())
    title = body['title']
    category = body['category']
    content = body['content']
    writer_id = body['writer_id']
    score = body['score']
    createdTime = datetime.datetime.now().isoformat()
    
    item = {
        'post_ID': postid,
        'title': title,
        'category': category,
        'content': content,
        'writer_id': writer_id,
        'score': score,
        'createdTime': createdTime,
    }
    try:
        post_table.put_item(Item = item)
    except ClientError as e:
        return {
            "statusCode": 500,
            "body": json.dumps("An error occurred while creating the post."),
        }
    return {
        "statusCode" : 200,
        "body" : json.dumps(f'{title} created!'),
    }

def read_post(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    post_table = dynamodb.Table(os.getenv("POST_TABLE_NAME"))
    body = json.loads(event['body'])

    try:
        response = post_table.scan()
    except Exception as e:
        return {
            "statusCode" : 500,
            "body" : json.dumps('An error occurred while reading posts.'),
        }

    if 'Item' in response:
        return {
            "statusCode" : 200,
            "body" : json.dumps('post read!'),
            "content" : response['Item']
        }
    else:
        return {
            "statusCode" : 404,
            "body" : json.dumps('post not found!'),
        }

def update_post(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    post_table = dynamodb.Table(os.getenv("POST_TABLE_NAME"))
    body = json.loads(event['body'])

    postid = body['post_ID']
    update_expression = 'SET title = :new_title, category = :new_category, content =: new_content, score =: new_score'
    expression_attribute_values = {
        ':new_title': body['title'],
        ':new_category': body['category'],
        ':new_content': body['content'],
        ':new_score': body['score'],
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
    post_table = dynamodb.Table(os.getenv("POST_TABLE_NAME"))
    body = json.loads(event['body'])

    postid = body['post_ID']

    try:
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
        "body" : json.dumps(''),
    }

def lambda_handler(event, context):
    body = json.loads(event['body'])
    if body['method']=='create_user':
        return create_user(event,context)
    elif body['method'] == 'read_user':
        return read_user(event, context)
    elif body['method'] == 'update_user':
        return update_user(event, context)
    elif body['method']=='delete_user':
        return delete_user(event, context)
    else:
        return {
            'statusCode':400,
            'body': json.dumps('Error')
        }