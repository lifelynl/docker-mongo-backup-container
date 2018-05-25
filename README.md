# Mongo backup container
This will make a mongodump backup of the database in the linked container. Then push it in a zipped tar file (e.g. "backup-2018-05-25-10-10-02.tar.gz") to S3.

# Usage
Run the docker container:

    docker run \
        --link mongo \
        --env AWS_ACCESS_KEY_ID= \
        --env AWS_SECRET_ACCESS_KEY= \
        --env AWS_S3_BUCKET= \
        mongo-backup-container

Or if the region is not eu-central-1:

    docker run \
        --link mongo \
        --env AWS_ACCESS_KEY_ID= \
        --env AWS_SECRET_ACCESS_KEY= \
        --env AWS_S3_BUCKET= \
        --env AWS_REGION=eu-west-1 \
        mongo-backup-container