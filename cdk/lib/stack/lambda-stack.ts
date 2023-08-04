import * as cdk from 'aws-cdk-lib'
import { CompositePrincipal, ManagedPolicy, Role, ServicePrincipal } from 'aws-cdk-lib/aws-iam';
import { Runtime } from 'aws-cdk-lib/aws-lambda';
import { Construct } from 'constructs'
import { getAccountUniqueName } from '../config/accounts';
import { SYSTEM_NAME } from '../config/common';
import { ReviewWebStackProps } from '../reviewweb-stack';
import { PythonFunction } from '@aws-cdk/aws-lambda-python-alpha';

import path = require('path');


export class ReviewWebLambdaStack extends cdk.Stack {
    public readonly LambdaFunction: PythonFunction;

    constructor(scope: Construct, id: string, props: ReviewWebStackProps) {
        super(scope, id, props);

        const lambdaRole = new Role(this, `${SYSTEM_NAME}-lambda-role`, {
            roleName: `${getAccountUniqueName(props.context)}`,
            assumedBy: new CompositePrincipal(
                new ServicePrincipal('lambda.amazonaws.com')

            ),

            managedPolicies: [
                ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSLambdaBasicExecutionRole'),
                ManagedPolicy.fromAwsManagedPolicyName('AmazonS3FullAccess'),
                ManagedPolicy.fromAwsManagedPolicyName('AmazonDynamoDBFullAccess'),
            ]
        });

        this.LambdaFunction = new PythonFunction(this, `${SYSTEM_NAME}-handler-file`, {
            functionName: `${getAccountUniqueName(props.context)}-reviewweb-handler-file`.toLowerCase(),
            handler: 'lambda_handler',
            entry: path.join(__dirname, '../../../app/backend'),
            index: 'lambda_handler.py',
            runtime: Runtime.PYTHON_3_10,
            role: lambdaRole,
            environment: {
                'BUCKET_NAME': props.s3Stack!.bucket.bucketName,
                'USER_TABLE_NAME': props.dynamoDBStack!.UserTable.tableName,
                'POST_TABLE_NAME': props.dynamoDBStack!.PostTable.tableName,
                'COMMENT_TABLE_NAME': props.dynamoDBStack!.CommentTable.tableName,
            },
        });
    }
}