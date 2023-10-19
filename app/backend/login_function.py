import boto3
import json
import os

def create_user(event, context):
    session = boto3.Session()
    cognito_client = session.client('cognito-idp', region_name=os.getenv("AWS_REGION"))
    
    body = json.loads(event['body'])
    entered_id = body['entered_id']
    entered_pw = body['entered_pw']

    try:
        response = cognito_client.sign_up(
            ClientId = os.getenv("AWS_CLIENT_ID"),
            Username = entered_id,
            Password = entered_pw,
        )
        return {
            'statusCode': 200,
            'body': json.dumps(f'{entered_id} saved!'),
        }
    except:
        return {
            'statusCode': 400,
            'body': json.dumps(f'{entered_id} already exists!')
        }

def read_user(event,context):
    session = boto3.Session()
    cognito_client = session.client('cognito-idp', region_name=os.getenv("AWS_REGION"))

    body = json.loads(event['body'])
    entered_id = body['entered_id']
    entered_pw = body['entered_pw']

    try:
        response = cognito_client.initiate_auth(
            ClientId = os.getenv("AWS_CLIENT_ID"),
            AuthFlow = 'USER_PASSWORD_AUTH',
            AuthParameters = {
                'USERNAME' : entered_id,
                'PASSWORD' : entered_pw,
            },
        )
        access_token = response['AuthenticateionResult']['AccessToken']
        return {
            'statusCode': 200,
            'body': json.dumps(access_token),
        }
    except:
        return {
            'statusCode': 404,
            'body': json.dumps(f'{entered_id} is wrong!')
        }

def update_user(event,context):
    session = boto3.Session()
    cognito_client = session.client('cognito-idp', region_name=os.getenv("AWS_REGION"))

    body = json.loads(event['body'])
    entered_id = body['entered_id']
    new_pw = body['entered_pw']
    try:
        response = cognito_client.admin_update_user_password(
            UserPoolId = os.getenv("AWS_USERPOOL_ID"),
            Username = entered_id,
            Password = new_pw,
        )
        return {
            'statusCode': 200,
            'body': json.dumps(f'{entered_id} updated!'),
        }
    except:
        return {
            'statusCode': 404,
            'body': json.dumps(f'{entered_id} not exist!')
        }

def delete_user(event, context):
    session = boto3.Session()
    cognito_client = session.client('cognito-idp', region_name=os.getenv("AWS_REGION"))
    body = json.loads(event['body'])

    entered_id = body['entered_id']

    try:
        response = cognito_client.admin_delete_user(
            UserPoolId = os.getenv("AWS_USERPOOL_ID"),
            Username = entered_id,
        )
        return {
            'statusCode': 200,
            'body': json.dumps(f'{entered_id} deleted!'),
        }
    except:
        return {
            'statusCode' : 400,
            'body': json.dumps(f'{entered_id} failed!'),
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