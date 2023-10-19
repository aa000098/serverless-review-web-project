import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { Accounts, getAccountUniqueName } from '../config/accounts';
import { SYSTEM_NAME } from '../config/common';
import { ReviewWebStackProps } from '../reviewweb-stack';
import * as cognito from 'aws-cdk-lib/aws-cognito';
import * as iam from 'aws-cdk-lib/aws-iam';

export class ReviewWebCognitoStack extends cdk.Stack {
    public userPool: cognito.UserPool
    public userPoolClient: cognito.UserPoolClient

    constructor(scope: Construct, id: string, props: ReviewWebStackProps) {
        super(scope, id, props);

        const userPool = new cognito.UserPool(this, `${SYSTEM_NAME}-UserPool`, {
            userPoolName: `${getAccountUniqueName(props.context)}-reviewweb-userpool`.toLowerCase(),
            selfSignUpEnabled: true,
            autoVerify: { email: true },
            signInAliases: { username: true, email: true },
            standardAttributes: {
                givenName: {
                    required: true,
                    mutable: true,
                },
                email: {
                    required: true,
                    mutable: false,
                },
            },
            customAttributes: {
                isAdmin: new cognito.StringAttribute({ mutable: true }),
            },
            passwordPolicy: {
                minLength: 6,
                requireLowercase: true,
                requireDigits: true,
            },
        });

        this.userPool = userPool

        const UserPoolClient = new cognito.UserPoolClient(this, `${SYSTEM_NAME}-UserPoolClient`, {
            userPool,
            authFlows: { userPassword: true },
        });

        this.userPoolClient = UserPoolClient

        const authenticatiedRole = new iam.Role(this, `${SYSTEM_NAME}-AuthenticatedRole`, {
            assumedBy: new iam.FederatedPrincipal(
                'cognito-identity.amazon.com',
                {
                    StringEquals: { 'cognito-identity.amazonaws.com:aud': userPool.userPoolId },
                    'ForAnyValue:StringLike': { 'cognito-identity.amazonaws.com:amr': 'authenticated' },
                },
                'sts:AssumeRoleWithWebIdentity'
            ),
        });

        authenticatiedRole.addToPolicy(new iam.PolicyStatement({
            actions: ['s3:GetObject', 's3:PutObject', 's3:DeleteObject'],
            resources: [`arn:aws:s3:::${props.s3Stack!.bucket.bucketName}/*`],
        }));

        authenticatiedRole.addToPolicy(new iam.PolicyStatement({
            actions: ['dynamodb:Query', 'dynamodb:PutItem'],
            resources: [`arn:aws:dynamodb:${Accounts[0].region}:${Accounts[0].accountID}:table/nf`]
        }));

        authenticatiedRole.addToPolicy(new iam.PolicyStatement({
            actions: ['execute-api:Invoke'],
            resources: [`arn:aws:execute-api:${Accounts[0].region}:${Accounts[0].accountID}:${props.apiGatewayStack?.api.restApiId}/*/GET/RESOURCE_PATH`],
        }))
    }
}