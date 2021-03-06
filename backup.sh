#! /bin/bash

# Exit if a command fails
set -e

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

BACKUP_NAME="backup-$(date -d "today" +"%Y-%m-%d-%H-%M-%S")"
if [ "${AWS_S3_BACKUP_NAME}" != "**None**" ]; then
  BACKUP_NAME="${AWS_S3_BACKUP_NAME}"
fi

if [ "${AWS_S3_ENABLE_VERSIONING}" != "**None**" ]; then
  /usr/local/bin/aws s3api put-bucket-versioning --bucket "${AWS_S3_BUCKET}" --versioning-configuration '{"Status":"Enabled"}'
fi

if [ "${AWS_S3_LIFECYLCE_CONFIGURATION}" != "**None**" ]; then
  /usr/local/bin/aws s3api put-bucket-lifecycle-configuration --bucket "${AWS_S3_BUCKET}" --lifecycle-configuration "${AWS_S3_LIFECYLCE_CONFIGURATION}"
fi

# Create required directory
mkdir -p /root/backup_temp/
rm -f /root/backup_temp/backup.archive.gz

# Make the mongodump backup
mongodump --archive="/root/backup_temp/backup.archive.gz" --host $MONGO_HOST --gzip

# Copy the backup to S3
if [ "${AWS_SSE_KEY}" = "**None**" ]; then
  /usr/local/bin/aws s3 cp /root/backup_temp/backup.archive.gz s3://$AWS_S3_BUCKET/$AWS_S3_PREFIX/$BACKUP_NAME.archive.gz
else
  /usr/local/bin/aws s3 cp --sse-c --sse-c-key="$AWS_SSE_KEY" /root/backup_temp/backup.archive.gz s3://$AWS_S3_BUCKET/$AWS_S3_PREFIX/$BACKUP_NAME.archive.gz
fi

# Remove the created backup directory
rm -rf /root/backup_temp
