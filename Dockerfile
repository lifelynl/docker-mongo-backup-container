FROM ubuntu:16.04
LABEL maintainer="Dirk Kok dirk@lifely.nl"

ENV AWS_ACCESS_KEY_ID **None**
ENV AWS_SECRET_ACCESS_KEY **None**
ENV AWS_SSE_KEY **None**
ENV AWS_S3_BUCKET **None**
ENV AWS_S3_PREFIX backup
ENV AWS_REGION eu-central-1
ENV SCHEDULE **None**
ENV MONGO_HOST mongo:27017
    
# Install everything and remove the bits we don't need anymore
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 \
    && echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list \
    && apt-get update \
    && apt-get install -y mongodb-org-tools \
\
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        python3-pip \
        python3-setuptools \
        python3-dev \
        python3-wheel \
    && pip3 install --upgrade pip \
    && pip install awscli \
\
    && curl -L https://github.com/odise/go-cron/releases/download/v0.0.6/go-cron-linux.gz | zcat > /usr/local/bin/go-cron \
    && chmod u+x /usr/local/bin/go-cron \
\
    && apt-get remove -y --purge --auto-remove \
        apt-transport-https \
        curl \
        python3-setuptools \
        python3-dev \
        python3-wheel \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

# Add
ADD run.sh run.sh
ADD backup.sh backup.sh

CMD ["sh", "run.sh"]