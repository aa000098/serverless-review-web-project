import json
import boto3
import os
import uuid
import datetime
from botocore.exceptions import ClientError

def create_comment(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    comment_table = dynamodb.Table(os.getenv("COMMENT_TABLE_NAME"))
    
    body = json.loads(event['body'])

    commentid = str(uuid.uuid4())
    postid = body['postid']
    content = body['content']
    writerid = body['writerid']
    createdTime = datetime.datetime.now().isoformat()
    
    item = {
        'comment_ID': commentid,
        'post_ID': postid,
        'content': content,
        'writerid': writerid,
        'createdTime': createdTime
    }
    
    try:
        comment_table.put_item(Item = item)
    except ClientError as e:
        return {
            "statusCode": 500,
            "body": json.dumps("An error occurred while creating the comment."),
        }
    return {
        "statusCode" : 200,
        "body" : json.dumps('comment created!'),
    }

def read_comment(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    comment_table = dynamodb.Table(os.getenv("COMMENT_TABLE_NAME"))
    
    try:
        response = comment_table.scan()
    except Exception as e:
        return {
            "statusCode" : 500,
            "body" : json.dumps('An error occurred while reading comments.'),
        }

    if 'Items' in response:
        items = response['Items']
        return {
            "statusCode" : 200,
            "body" : json.dumps(items),
        }
    else:
        return {
            "statusCode" : 404,
            "body" : json.dumps('comment not found!'),
        }


def update_comment(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    comment_table = dynamodb.Table(os.getenv("COMMENT_TABLE_NAME"))
    body = json.loads(event['body'])
    
    commentid = body['comment_ID']
    
    update_expression = 'SET content = :new_content'
    expression_attribute_values = {
        ':new_content': body['content'],
    }
    
    try:
        response = comment_table.update_item(
            Key = {
                'comment_ID': commentid,
            },
            UpdateExpression = update_expression,
            ExpressionAttributeValues = expression_attribute_values
        )
    except Exception as e:
        return {
            "statusCode" : 500,
            "body": json.dumps('An error occurred while updating the comment.'),
        }

    return {
        "statusCode" : 200,
        "body" : json.dumps('comment updated!'),
    }

def delete_comment(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    comment_table = dynamodb.Table(os.getenv("COMMENT_TABLE_NAME"))
    body = json.loads(event['body'])
    
    commentid = body['comment_ID']

    try:
        response = comment_table.delete_item(
            Key = {
                'comment_ID' : commentid,
            }
        )
    except Exception as e:
        return {
            "statusCode" : 500,
            "body": json.dumps('An error occurred while deleting the comment.'),
        }
    return {
        "statusCode" : 200,
        "body" : json.dumps('comment deleted!'),
    }

def lambda_handler(event, context):
    http_method = event['httpMethod']
    if http_method =='POST':
        return create_comment(event,context)
    elif http_method == 'GET':
        return read_comment(event, context)
    elif http_method == 'PATCH':
        return update_comment(event, context)
    elif http_method =='DELETE':
        return delete_comment(event, context)
    else:
        return {
            'statusCode':400,
            'body': json.dumps('Error')
        }