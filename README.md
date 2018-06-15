# Mongo backup container
This container will make a mongodump backup of the given MongoDB host (default: mongo:27017). It'll then push the backup to S3 in a zipped tar file (e.g. "backup-2018-05-25-10-10-02.tar.gz").

Currently using MongoDB 3.4.

Inspired by [schickling/postgres-backup-s3](https://hub.docker.com/r/schickling/postgres-backup-s3/).

# Usage
Run the docker container:

    docker run \
        --env AWS_ACCESS_KEY_ID= \
        --env AWS_SECRET_ACCESS_KEY= \
        --env AWS_S3_BUCKET= \
        lifely/mongo-backup-container

The variables AWS_S3_PREFIX, AWS_REGION, MONGO_HOST, SCHEDULE and AWS_SSE_KEY are optional:

    docker run \
        --env AWS_ACCESS_KEY_ID= \
        --env AWS_SECRET_ACCESS_KEY= \
        --env AWS_S3_BUCKET= \
        --env AWS_S3_PREFIX= \
        --env AWS_REGION=eu-west-1 \
        --env MONGO_HOST=mongo:27017 \
        --env SCHEDULE="0 * * * *" \
        --env AWS_SSE_KEY= \
        lifely/mongo-backup-container

## Docker compose
Docker compose will start a mongo container exposing port 27017 and a backup container that will run the backup script every minute. Don't forget to set the AWS credentials.

### Automatic Periodic Backups
You can set the `SCHEDULE` environment variable like `-e SCHEDULE="0 * * * *"` (hourly) to run the backup automatically. This uses regular cron syntax: minute hour day-of-month month day-of-week

### AWS SSE
The AWS_SSE_KEY should be a string of [exactly 32 characters](https://stackoverflow.com/a/35905265).
