FROM ubuntu:16.04

ENV GOPATH /root

ENV AWS_ACCESS_KEY_ID **None**
ENV AWS_SECRET_ACCESS_KEY **None**
ENV AWS_S3_BUCKET **None**
ENV AWS_REGION eu-central-1

# Install basic stuff
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    binutils \
    golang-go \
    git

# Install mongo tools
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/testing multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list && \
    apt-get update && \
    apt-get install -y mongodb-org-tools

# Install S3 client
RUN go get github.com/barnybug/s3 && \
    cd /root/src/github.com/barnybug/s3/ && \
    go install -v ./cmd/s3 && \
    strip /root/bin/s3 && \
    mv /root/bin/s3 /usr/local/bin && \
    rm -rf /root/*

# Cleanup dependencies
RUN apt-get remove -y --purge \
    apt-transport-https \
    binutils \
    golang-go \
    git
RUN apt-get autoremove -y
RUN apt-get clean

# Add 
ADD backup.sh backup.sh

CMD ["sh", "backup.sh"]