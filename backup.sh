#! /bin/bash

# Exit if a command fails
set -e

# When started from cron, this script doesn't have the right env vars
# we need to load them from this file
FILE=/root/.docker_env     
if [ -f $FILE ]; then
   source $FILE
fi

if [ "${AWS_ACCESS_KEY_ID}" = "**None**" ]; then
  echo "You need to set the AWS_ACCESS_KEY_ID environment variable."
  exit 1
fi

if [ "${AWS_SECRET_ACCESS_KEY}" = "**None**" ]; then
  echo "You need to set the AWS_SECRET_ACCESS_KEY environment variable."
  exit 1
fi

if [ "${AWS_S3_BUCKET}" = "**None**" ]; then
  echo "You need to set the AWS_S3_BUCKET environment variable."
  exit 1
fi

# Create required directories
mkdir /root/backup_temp/
mkdir /root/backup_temp/original

# Make the mongodump backup
mongodump --out /root/backup_temp/original --host $MONGO_HOST

# Archive + zip and remove the original backup files
tar -czvf /root/backup_temp/backup.tar.gz /root/backup_temp/original
rm -rf /root/backup_temp/original

# Copy the backup to S3
# Somehow we need so explicitly set environment variables
if [ "${AWS_SSE_KEY}" = "**None**" ]; then
  AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID /usr/local/bin/aws s3 cp /root/backup_temp/backup.tar.gz s3://$AWS_S3_BUCKET/backup-$(date -d "today" +"%Y-%m-%d-%H-%M-%S").tar.gz
else
  AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID /usr/local/bin/aws s3 cp --sse-c --sse-c-key="$AWS_SSE_KEY" /root/backup_temp/backup.tar.gz s3://$AWS_S3_BUCKET/backup-$(date -d "today" +"%Y-%m-%d-%H-%M-%S").tar.gz
fi

# Remove the created backup directory
rm -rf /root/backup_temp