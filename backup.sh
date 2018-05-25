#! /bin/sh

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

# Create required directories
mkdir /root/backup_temp/
mkdir /root/backup_temp/original

# Make the mongodump backup
mongodump --out /root/backup_temp/original --host mongo:27017

# Archive + zip and remove the original backup files
tar -czvf /root/backup_temp/backup-$(date -d "today" +"%Y-%m-%d-%H-%M-%S").tar.gz /root/backup_temp/original
rm -rf /root/backup_temp/original

# Sync the backup to S3
s3 sync /root/backup_temp/* s3://$AWS_S3_BUCKET

# Remove the created backup directory
rm -rf /root/backup_temp