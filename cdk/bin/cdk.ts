#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { ReviewWebStack } from '../lib/reviewweb-stack';
import * as os from 'os';
import { getAccountUniqueName, getDevAccount } from '../lib/config/accounts';

const app = new cdk.App();

let userName = os.userInfo().username
console.log(userName);

const devAccount = getDevAccount(userName);
if (devAccount !== undefined) {

  new ReviewWebStack(app, `${getAccountUniqueName(devAccount)}`, {
    env: devAccount,
    context: devAccount,
  });
}