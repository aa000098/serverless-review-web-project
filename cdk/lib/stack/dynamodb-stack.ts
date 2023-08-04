import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { ReviewWebStackProps } from '../reviewweb-stack';
import * as dynamoDB from 'aws-cdk-lib/aws-dynamodb';
import { SYSTEM_NAME } from '../config/common';
import { getAccountUniqueName } from '../config/accounts';

export class ReviewWebDynamoDBStack extends cdk.Stack {
  public UserTable: dynamoDB.ITable
  public PostTable: dynamoDB.ITable
  public CommentTable: dynamoDB.ITable

  constructor(scope: Construct, id: string, props: ReviewWebStackProps) {
    super(scope, id, props);

    const UserTable = new dynamoDB.Table(this, `${SYSTEM_NAME}-UserTable`, {
      tableName: `${getAccountUniqueName(props.context)}-reviewweb-user-table`.toLowerCase(),
      partitionKey: { name: 'UserID', type: dynamoDB.AttributeType.STRING },
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    const PostTable = new dynamoDB.Table(this, `${SYSTEM_NAME}-PostTable`, {
      tableName: `${getAccountUniqueName(props.context)}-reviewweb-post-table`.toLowerCase(),
      partitionKey: { name: 'postID', type: dynamoDB.AttributeType.STRING },
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    const CommentTable = new dynamoDB.Table(this, `${SYSTEM_NAME}-CommentTable`, {
      tableName: `${getAccountUniqueName(props.context)}-reviewweb-comment-table`.toLowerCase(),
      partitionKey: { name: 'commentID', type: dynamoDB.AttributeType.STRING },
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    this.UserTable = UserTable;
    this.PostTable = PostTable;
    this.CommentTable = CommentTable;
  }
}