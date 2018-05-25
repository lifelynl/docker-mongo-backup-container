FROM ubuntu:16.04
LABEL maintainer="Dirk Kok dirk@lifely.nl"

ENV GOPATH /root

ENV AWS_ACCESS_KEY_ID **None**
ENV AWS_SECRET_ACCESS_KEY **None**
ENV AWS_S3_BUCKET **None**
ENV AWS_REGION eu-central-1
ENV SCHEDULE **None**
ENV MONGO_HOST mongo:27017

# Install basic stuff
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        binutils \
        golang-go \
        git \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Install go-cron
RUN curl -L https://github.com/odise/go-cron/releases/download/v0.0.6/go-cron-linux.gz | zcat > /usr/local/bin/go-cron \
    && chmod u+x /usr/local/bin/go-cron
    
# Install mongo tools
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 \
    && echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list \
    && apt-get update \
    && apt-get install -y mongodb-org-tools \
    && rm -rf /var/lib/apt/lists/*

# Install S3 client
RUN go get github.com/barnybug/s3 \
    && cd /root/src/github.com/barnybug/s3/ \
    && go install -v ./cmd/s3 \
    && strip /root/bin/s3 \
    && mv /root/bin/s3 /usr/local/bin \
    && rm -rf /root/*

# Cleanup dependencies
RUN apt-get remove -y --purge --auto-remove \
        apt-transport-https \
        binutils \
        golang-go \
        git \
        curl \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

# Add 
ADD run.sh run.sh
ADD backup.sh backup.sh

CMD ["sh", "run.sh"]