import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { getAccountUniqueName } from '../config/accounts';
import { SYSTEM_NAME } from '../config/common';
import { ReviewWebStackProps } from '../reviewweb-stack';
import * as ApiGateway from 'aws-cdk-lib/aws-apigateway'

export class ReviewWebApigatewayStack extends cdk.Stack {
    public apigw: ApiGateway.IRestApi

    constructor(scope: Construct, id: string, props: ReviewWebStackProps) {
        super(scope, id, props);

        const apigw = new ApiGateway.RestApi(this, `${SYSTEM_NAME}-ApiGateway`, {
            restApiName: `${getAccountUniqueName(props.context)}-rewviewweb-apigateway`.toLowerCase(),
            description: 'ReviewWeb API Gateway'
        });

        this.apigw = apigw;

        const LoginFunction = props.lambdaStack?.LoginFunction
        const ReviewFunction = props.lambdaStack?.ReviewFunction

        if (LoginFunction != null) {
            const login_integration = new ApiGateway.LambdaIntegration(LoginFunction);
            const login_resource = apigw.root.addResource(`${SYSTEM_NAME}-apigw-login-resource`);
            login_resource.addMethod('GET', login_integration);
            login_resource.addMethod('POST', login_integration);
            login_resource.addMethod('UPDATE', login_integration);
            login_resource.addMethod('DELETE', login_integration);
        }

        if (ReviewFunction != null) {
            const review_integration = new ApiGateway.LambdaIntegration(ReviewFunction);
            const review_resource = apigw.root.addResource(`${SYSTEM_NAME}-apigw-review-resource`);
            review_resource.addMethod('GET', review_integration);
            review_resource.addMethod('POST', review_integration);
            review_resource.addMethod('UPDATE', review_integration);
            review_resource.addMethod('DELETE', review_integration);
        }
    }
}