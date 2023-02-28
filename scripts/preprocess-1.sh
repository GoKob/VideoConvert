#!/bin/bash

Prefix=$1

openssl genrsa -out cloudfront_private_key.pem 2048
openssl rsa -pubout -in cloudfront_private_key.pem -out cloudfront_public_key.pem
EncodedKey="$(cat ./cloudfront_public_key.pem)"

sed \
-e "s%TEPMLATE_ENCODED_PUBLIC_KEY%$(echo $EncodedKey)%g" \
-e "s%TEPMLATE_NAME%$(echo $Prefix)-pulic-key%g" \
./cloudfront_key_config.json.tmpl > ./cloudfront_key_config.json
sed -i 's/- /-\\n/ ; s/ -/\\n-/' ./cloudfront_key_config.json
CloudfrontKeyID=$(aws cloudfront create-public-key --public-key-config file://cloudfront_key_config.json --query 'PublicKey'.'Id' --output text)
echo "CloudFront public key created! now creating cloudfront key group ..."


sleep 10s
echo "CloudFrontKeyId: $CloudfrontKeyID"
sed \
-e "s%TEMPLATE_KEY_ID%$(echo $CloudfrontKeyID)%g" \
-e "s%TEMPLATE_KEY_GROUP_NAME%$(echo $Prefix)-key-group%g" \
./cloudfront_key_group_config.json.tmpl > ./cloudfront_key_group_config.json
CloudFrontKeyGroup=$(aws cloudfront create-key-group --key-group-config file://cloudfront_key_group_config.json --query 'KeyGroup'.'Id' --output text)
echo "CloudFrontKeyGroup: $CloudFrontKeyGroup"

SecretManagerName=$(aws secretsmanager create-secret --name $Prefix-cloudfront-key-pair --secret-binary file://cloudfront_private_key.pem --query 'Name' --output text)
echo "SecretName: $SecretManagerName"


echo "Upload private key to secretsmanager"
sed -i \
-e "s%TEMPLATE_CLOUDFRONT_KEY_PAIR_ID%$(echo $CloudfrontKeyID)%g" \
-e "s%TEMPLATE_KSECRET_NAME%$(echo $SecretManagerName)%g" \
../amplify/backend/function/GetCredential/GetCredential-cloudformation-template.json


echo "Create cloudformation stack"
aws cloudformation create-stack --stack-name $Prefix-videoconvert --parameters ParameterKey=MediaPackageOutputBucketPrefix,ParameterValue=$Prefix ParameterKey=TrustedKeyGroup,ParameterValue=$CloudFrontKeyGroup ParameterKey=MediaConvertOutputBucket,ParameterValue='' --template-body file://cloudformation/VideoConvert.yml --capabilities CAPABILITY_NAMED_IAM --output text
