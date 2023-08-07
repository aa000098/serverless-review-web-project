import json
import boto3
import os

def create(event, context):
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