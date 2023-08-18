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
    public readonly LoginFunction: PythonFunction;
    public readonly PostFunction: PythonFunction;
    public readonly CommentFunction: PythonFunction;

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

        this.LoginFunction = new PythonFunction(this, `${SYSTEM_NAME}-login-file`, {
            functionName: `${getAccountUniqueName(props.context)}-reviewweb-login-file`.toLowerCase(),
            handler: 'lambda_handler',
            entry: path.join(__dirname, '../../../app/backend'),
            index: 'login_function.py',
            runtime: Runtime.PYTHON_3_10,
            role: lambdaRole,
            environment: {
                'USER_TABLE_NAME': props.dynamoDBStack!.UserTable.tableName,
                'TZ': 'Asia/Seoul',
            },
        });


        this.PostFunction = new PythonFunction(this, `${SYSTEM_NAME}-post-file`, {
            functionName: `${getAccountUniqueName(props.context)}-reviewweb-post-file`.toLowerCase(),
            handler: 'lambda_handler',
            entry: path.join(__dirname, '../../../app/backend'),
            index: 'post_function.py',
            runtime: Runtime.PYTHON_3_10,
            role: lambdaRole,
            environment: {
                'POST_TABLE_NAME': props.dynamoDBStack!.PostTable.tableName,
                'BUCKET_NAME': props.s3Stack!.bucket.bucketName,
                'TZ': 'Asia/Seoul',
            },
        });

        this.CommentFunction = new PythonFunction(this, `${SYSTEM_NAME}-comment-file`, {
            functionName: `${getAccountUniqueName(props.context)}-reviewweb-comment-file`.toLowerCase(),
            handler: 'lambda_handler',
            entry: path.join(__dirname, '../../../app/backend'),
            index: 'comment_function.py',
            runtime: Runtime.PYTHON_3_10,
            role: lambdaRole,
            environment: {
                'COMMENT_TABLE_NAME': props.dynamoDBStack!.CommentTable.tableName,
                'TZ': 'Asia/Seoul',
            },
        });
    }
}