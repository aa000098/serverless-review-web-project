import boto3
import json
import os

def create_user(event, context):
    session = boto3.Session()
    dynamodb = session.resource('dynamodb')
    user_table = dynamodb.Table(os.getenv("USER_TABLE_NAME"))

    entered_id = event['entered_id']
    entered_pw = event['entered_pw']
    
    response = user_table.get_item(
        Key={
            'id': entered_id
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
                'id' : entered_id,
                'pw' : entered_pw,
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

    entered_id = event['entered_id']
    entered_pw = event['entered_pw']

    response = user_table.get_item(
        Key={
            'id': entered_id
        }
    )

    if 'Item' in response:
        pw = response['Item']['pw']
        if entered_pw == pw:
            return {
                'statusCode': 200,
                'body': json.dumps(f'{entered_id} match!'),
                'id': entered_id
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

    entered_id = event['entered_id']
    new_pw = event['entered_pw']

    response = user_table.get_item(
        Key={
            'id': entered_id
        }
    )
    
    if 'Item' in response:

        update_expression = 'SET pw = :new_pw'
        expression_attribute_values = {':new_pw': new_pw}

        user_table.update_item(
            Key={
                'id' : entered_id
            },
            UpdateExpression = update_expression,
            expression_attribute_values= expression_attribute_values
        )
        return {
            'statusCode': 200,
            'body': json.dumps(f'{entered_id} changed!'),
            'id': entered_id
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

    entered_id = event['entered_id']

    response = user_table.get_item(
        Key={
            'id': entered_id
        }
    )
    
    if 'Item' in response:
        user_table.delete_item(
            Key={
                'id' : entered_id
            },
        )
        return {
            'statusCode': 200,
            'body': json.dumps(f'{entered_id} deleted!'),
            'id': entered_id
        }


def lambda_handler(event, context):
    if event['method']=='create_user':
        return create_user(event,context)
    elif event['method'] == 'read_user':
        return read_user(event, context)
    elif event['method'] == 'update_user':
        return update_user(event, context)
    elif event['method']=='delete_user':
        return delete_user(event, context)
