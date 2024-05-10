#!/bin/bash
aws cloudformation validate-template --template-body file://cfn.yml --region eu-central-1
aws cloudformation deploy --stack-name test-stack-shaheer --template-file cfn.yml --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --region eu-central-1
aws s3 cp index.html s3://shaheer-gogift-cfn-test/ --region eu-central-1