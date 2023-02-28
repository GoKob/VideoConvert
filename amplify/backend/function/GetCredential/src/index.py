import os
import json
import boto3
import base64
from datetime import datetime, timedelta
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import padding
from botocore.signers import CloudFrontSigner
from botocore.exceptions import ClientError


def get_secret():
  secret_name = os.environ["SECRET_NAME"]
  region_name = os.environ['AWS_REGION']

  session = boto3.session.Session()
  client = session.client(
    service_name='secretsmanager',
    region_name=region_name
  )

  try:
    get_secret_value_response = client.get_secret_value(
      SecretId=secret_name
    )
  except ClientError as e:
    raise e

  return get_secret_value_response['SecretBinary']


def rsa_signer(message):
  priv_key = get_secret()
  private_key = serialization.load_pem_private_key(
    priv_key,
    password=None,
    backend=default_backend()
  )
  
  return private_key.sign(message, padding.PKCS1v15(), hashes.SHA1())


def get_signedurl(rsa_signer, key_pair_id, resource_url, expire_at):
  cf_signer = CloudFrontSigner(key_pair_id, rsa_signer)
  policy = cf_signer.build_policy(resource_url, expire_at)
  signed_url = cf_signer.generate_presigned_url(resource_url, date_less_than=None, policy=policy)

  return signed_url


def handler(event, context):
  resource_url = event['queryStringParameters']['resource_url'] + "*"
  expire_at = datetime.now() + timedelta(days=1)
  key_pair_id = os.environ['CLOUDFRONT_KEY_PAIR_ID']
  
  signed_url = get_signedurl(rsa_signer, key_pair_id, resource_url, expire_at)
  query = signed_url.split('?')[1]
  
  return {
    'statusCode': 200,
    'headers': {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Credentials': True,
    },
    'body': query
  }

