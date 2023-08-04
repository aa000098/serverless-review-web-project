import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { getAccountUniqueName } from '../config/accounts';
import { SYSTEM_NAME } from '../config/common';
import { ReviewWebStackProps } from '../reviewweb-stack';
import * as ApiGateway from 'aws-cdk-lib/aws-apigateway'
import { ReviewWebLambdaStack } from './lambda-stack';

export class ReviewWebApigatewayStack extends cdk.Stack {
    public apigw: ApiGateway.IRestApi

    constructor(scope: Construct, id: string, props: ReviewWebStackProps) {
        super(scope, id, props);

        const apigw = new ApiGateway.RestApi(this, `${SYSTEM_NAME}-ApiGateway`, {
            restApiName: `${getAccountUniqueName(props.context)}-rewviewweb-apigateway`.toLowerCase(),
            description: 'ReviewWeb API Gateway'
        });

        this.apigw = apigw;

        const LambdaFunction = props.lambdaStack?.LambdaFunction
        if (LambdaFunction != null) {
            const integration = new ApiGateway.LambdaIntegration(LambdaFunction);
            const resource = apigw.root.addResource(`${SYSTEM_NAME}-apigw-resource`);
            resource.addMethod('GET', integration);
        }



    }
}