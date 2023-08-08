import boto3
import json
import os

def create_user(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    user_table = dynamodb.Table(os.getenv("USER_TABLE_NAME"))
    body = json.loads(event['body'])

    entered_id = body['entered_id']
    entered_pw = body['entered_pw']
    
    response = user_table.get_item(
        Key={
            'user_ID': entered_id
        }
    )

    if 'Item' in response:
        return {
            'statusCode': 400,
            'body': json.dumps(f'{entered_id} already exists!')
        }
    else:
        user_table.put_item(
            Item={
                'user_ID' : entered_id,
                'user_PW' : entered_pw,
            }
        )
        return {
            'statusCode': 200,
            'body': json.dumps(f'{entered_id} saved!'),
        }


def read_user(event,context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    user_table = dynamodb.Table(os.getenv("USER_TABLE_NAME"))
    body = json.loads(event['body'])

    entered_id = body['entered_id']
    entered_pw = body['entered_pw']

    response = user_table.get_item(
        Key={
            'user_ID': entered_id
        }
    )

    if 'Item' in response:
        pw = response['Item']['user_PW']
        if entered_pw == pw:
            return {
                'statusCode': 200,
                'body': json.dumps(f'{entered_id} match!'),
            }
        else:
            return {
                'statusCode' : 401,
                'body' : json.dumps(f'{entered_id} mismatch!')
            }
    else:
        return {
            'statusCode': 404,
            'body': json.dumps(f'{entered_id} not exist!')
        }

def update_user(event,context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    user_table = dynamodb.Table(os.getenv("USER_TABLE_NAME"))
    body = json.loads(event['body'])

    entered_id = body['entered_id']
    new_pw = body['entered_pw']

    response = user_table.get_item(
        Key={
            'user_ID': entered_id
        }
    )
    
    if 'Item' in response:

        update_expression = 'SET user_PW = :new_pw'
        expression_attribute_values = {':new_pw': new_pw}

        user_table.update_item(
            Key={
                'user_ID' : entered_id
            },
            UpdateExpression = update_expression,
            expression_attribute_values= expression_attribute_values
        )
        return {
            'statusCode': 200,
            'body': json.dumps(f'{entered_id} updated!'),
        }
    else:
        return {
            'statusCode': 404,
            'body': json.dumps(f'{entered_id} not exist!')
        }

def delete_user(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    user_table = dynamodb.Table(os.getenv("USER_TABLE_NAME"))
    body = json.loads(event['body'])

    entered_id = body['entered_id']

    response = user_table.get_item(
        Key={
            'user_ID': entered_id
        }
    )
    
    if 'Item' in response:
        user_table.delete_item(
            Key={
                'user_ID' : entered_id
            },
        )
        return {
            'statusCode': 200,
            'body': json.dumps(f'{entered_id} deleted!'),
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