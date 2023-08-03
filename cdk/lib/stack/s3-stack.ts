import * as cdk from 'aws-cdk-lib';
import * as s3 from 'aws-cdk-lib/aws-s3';
import { Construct } from 'constructs';
import { getAccountUniqueName } from '../config/accounts';
import { SYSTEM_NAME } from '../config/common';
import { ReviewWebStackProps } from '../reviewweb-stack';

export class ReviewWebS3Stack extends cdk.Stack {
    public bucket: s3.IBucket;

    constructor(scope: Construct, id: string, props: ReviewWebStackProps) {
        super(scope, id, props);

        const bucket = new s3.Bucket(this, `${SYSTEM_NAME}-S3`, {
            bucketName: `${getAccountUniqueName(props.context)}-reviewweb-bucket`.toLowerCase(),
            publicReadAccess: false,
            blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
            encryption: s3.BucketEncryption.S3_MANAGED,
        });

        this.bucket = bucket;
    }
}