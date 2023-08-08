import json
import boto3
import os

def create_comment(event, context):
    return {
        "statusCode" : 200,
        "body" : json.dumps(''),
    }

def read_comment(event, context):
    return {
        "statusCode" : 200,
        "body" : json.dumps(''),
    }

def update_comment(event, context):
    return {
        "statusCode" : 200,
        "body" : json.dumps(''),
    }

def delete_comment(event, context):
    return {
        "statusCode" : 200,
        "body" : json.dumps(''),
    }

def lambda_handler(event, context):
    body = json.loads(event['body'])
    if body['method']=='create_comment':
        return create_comment(event,context)
    elif body['method'] == 'read_comment':
        return read_comment(event, context)
    elif body['method'] == 'update_comment':
        return update_comment(event, context)
    elif body['method']=='delete_comment':
        return delete_comment(event, context)
    else:
        return {
            'statusCode':400,
            'body': json.dumps('Error')
        }