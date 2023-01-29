import json
import boto3
import os
import datetime
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

mediapackage = boto3.client('mediapackage')

def handler(event, context):
  logger.info(event)
  
  now = datetime.datetime.now()
  reqData = json.loads(event["body"])
  
  res = mediapackage.create_harvest_job(
    EndTime=reqData["end"],
    Id="harvestjob-%s" % int(now.timestamp()),
    OriginEndpointId=os.environ["OriginEndpointID"],
    S3Destination={
        'BucketName': os.environ["DestinationS3Bucket"],
        'ManifestKey': "harvest-job/%s/video.m3u8" % reqData["folder"],
        'RoleArn': os.environ["DestinationRoleArn"]
    },
    StartTime=reqData["start"]
  )
  
  logger.info(res)

  return {
      'statusCode': 200,
      'headers': {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'OPTIONS,POST'
      },
      'body': json.dumps(res)
  }
