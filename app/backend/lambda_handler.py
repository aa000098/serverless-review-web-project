import json
import boto3
import os

def create(event, context):
    return {
        "statusCode" : 200,
        "body" : json.dumps(''),
    }

def lambda_handler(event, context):
    if event['method'] == 'create' :
        return create(event, context)
    elif event['method'] == 'read' :
        return create(event, context)
    elif event['method'] == 'update' :
        return create(event, context)
    elif event['method'] == 'delete' :
        return create(event, context)
    else:
        return {
            'satusCode':400,
            'body': json.dumps('Error')
        }