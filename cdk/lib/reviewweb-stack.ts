import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { Account } from './config/accounts';
import { SYSTEM_NAME } from './config/common';
import { ReviewWebApigatewayStack } from './stack/apigateway-stack';
import { ReviewWebDynamoDBStack } from './stack/dynamodb-stack';
import { ReviewWebLambdaStack } from './stack/lambda-stack';
import { ReviewWebS3Stack } from './stack/s3-stack';
// import * as sqs from 'aws-cdk-lib/aws-sqs';

export interface ReviewWebStackProps extends cdk.StackProps {
  context: Account
  s3Stack?: ReviewWebS3Stack
  dynamoDBStack?: ReviewWebDynamoDBStack
  apiGatewayStack?: ReviewWebApigatewayStack
  lambdaStack?: ReviewWebLambdaStack
}

export class ReviewWebStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: ReviewWebStackProps) {
    super(scope, id, props);
    const s3Stack = new ReviewWebS3Stack(this, `${SYSTEM_NAME}-s3Stack`, props);
    props.s3Stack = s3Stack;

    const dynamoDBStack = new ReviewWebDynamoDBStack(this, `${SYSTEM_NAME}-dynamoDBStack`, props);
    props.dynamoDBStack = dynamoDBStack;

    const lambdaStack = new ReviewWebLambdaStack(this, `${SYSTEM_NAME}-lambdaStack`, props);
    props.lambdaStack = lambdaStack;
    const apiGatewayStack = new ReviewWebApigatewayStack(this, `${SYSTEM_NAME}-apigatewayStack`, props);
    props.apiGatewayStack = apiGatewayStack;


  }
}
