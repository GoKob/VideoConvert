#!/bin/bash

Prefix=$1

CludFormationStack=$(aws cloudformation describe-stacks --stack-name $Prefix-videoconvert --query 'Stacks[0]'.'Outputs[*]'.'OutputValue' --output json)
CloudFrontUrl=$(echo $CludFormationStack | jq .[0] | tr -d '"')
OriginEndpointID=$(echo $CludFormationStack | jq .[1] | tr -d '"')
DestinationS3Bucket=$(echo $CludFormationStack | jq .[2] | tr -d '"')
DestinationRoleArn=$(echo $CludFormationStack | jq .[3] | tr -d '"')

sed -i \
-e "s%TEMPLATE_OriginEndpointID%$(echo $OriginEndpointID)%g" \
-e "s%TEMPLATE_DestinationS3Bucket%$(echo $DestinationS3Bucket)%g" \
-e "s%TEMPLATE_DestinationRoleArn%$(echo $DestinationRoleArn)%g" \
../amplify/backend/function/VideoconvertRequest/VideoconvertRequest-cloudformation-template.json


Url=$CloudFrontUrl$(aws mediapackage describe-origin-endpoint --id $OriginEndpointID --query 'Url' --output text | sed -e "s/.*\(\/out\/.*\/\).*/\1/g")
sed -i \
-e "s%TEMPLATE_URL%$(echo $Url)%g" \
../src/components/Home.vue 
