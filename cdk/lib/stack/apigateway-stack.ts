import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { getAccountUniqueName } from '../config/accounts';
import { SYSTEM_NAME } from '../config/common';
import { ReviewWebStackProps } from '../reviewweb-stack';
import * as ApiGateway from 'aws-cdk-lib/aws-apigateway'
import { EndpointType, LogGroupLogDestination, MethodLoggingLevel } from 'aws-cdk-lib/aws-apigateway';
import { LogGroup } from 'aws-cdk-lib/aws-logs';

export class ReviewWebApigatewayStack extends cdk.Stack {
    public api: ApiGateway.IRestApi

    constructor(scope: Construct, id: string, props: ReviewWebStackProps) {
        super(scope, id, props);

        const api = new ApiGateway.RestApi(this, `${SYSTEM_NAME}-ApiGateway`, {
            restApiName: `${getAccountUniqueName(props.context)}-reviewweb-apigateway`.toLowerCase(),
            description: `${SYSTEM_NAME} Application API`,
            deployOptions: {
                stageName: 'dev',
                metricsEnabled: true,
                loggingLevel: MethodLoggingLevel.INFO,
                accessLogDestination: new LogGroupLogDestination(
                    new LogGroup(this, `${getAccountUniqueName(props.context)}-api-log-group`, {
                        logGroupName: `/API-Gateway/${getAccountUniqueName(props.context)}-reviewweb-api`,
                        removalPolicy: props.terminationProtection ? cdk.RemovalPolicy.RETAIN : cdk.RemovalPolicy.DESTROY,
                    })
                ),
            },
            endpointTypes: [EndpointType.REGIONAL],
            retainDeployments: props.terminationProtection,
            cloudWatchRole: true,
        });

        const apiKey = api.addApiKey(`${SYSTEM_NAME}-ApiKey`, {
            apiKeyName: `${getAccountUniqueName(props.context)}`,
            description: 'Rewviewweb API Key',
        });

        const usagePlan = api.addUsagePlan(`${SYSTEM_NAME}-UsagePlan`, {
            name: `${getAccountUniqueName(props.context)}-UsagePlan`,
            apiStages: [
                {
                    api: api,
                    stage: api.deploymentStage,
                },
            ],
        });
        usagePlan.addApiKey(apiKey);

        const methodOpthis = {
            apiKeyRequired: true,
        };


        this.api = api;

        const LoginFunction = props.lambdaStack?.LoginFunction
        const PostFunction = props.lambdaStack?.PostFunction
        const CommentFunction = props.lambdaStack?.CommentFunction

        if (LoginFunction != null) {
            const login_integration = new ApiGateway.LambdaIntegration(LoginFunction);
            const login_resource = api.root.addResource(`${SYSTEM_NAME}-apigw-login-resource`);
            login_resource.addMethod('GET', login_integration, methodOpthis);
            login_resource.addMethod('POST', login_integration, methodOpthis);
            login_resource.addMethod('PATCH', login_integration, methodOpthis);
            login_resource.addMethod('DELETE', login_integration, methodOpthis);
        }

        if (PostFunction != null) {
            const post_integration = new ApiGateway.LambdaIntegration(PostFunction);
            const post_resource = api.root.addResource(`${SYSTEM_NAME}-apigw-post-resource`);
            post_resource.addMethod('GET', post_integration, methodOpthis);
            post_resource.addMethod('POST', post_integration, methodOpthis);
            post_resource.addMethod('PATCH', post_integration, methodOpthis);
            post_resource.addMethod('DELETE', post_integration, methodOpthis);
        }

        if (CommentFunction != null) {
            const comment_integration = new ApiGateway.LambdaIntegration(CommentFunction);
            const comment_resource = api.root.addResource(`${SYSTEM_NAME}-apigw-comment-resource`);
            comment_resource.addMethod('GET', comment_integration, methodOpthis);
            comment_resource.addMethod('POST', comment_integration, methodOpthis);
            comment_resource.addMethod('PATCH', comment_integration, methodOpthis);
            comment_resource.addMethod('DELETE', comment_integration, methodOpthis);
        }
    }
}