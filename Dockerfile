FROM ubuntu:14.04
FROM python:3
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash
#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common python-software-properties
#RUN add-apt-repository ppa:chris-lea/redis-server

MAINTAINER Alexander Swensen <alex.swensen@gmail.com>

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install Required Packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y python-pip build-essential python-dev mysql-server nodejs nginx python-software-properties software-properties-common

# install NVM
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.5/install.sh | bash

ENV NODE_VERSION 6.11.1

# Install a version of node & latest npm
RUN source /root/.bashrc && \
    cd /root && \
    nvm install $NODE_VERSION && \
    npm install -g npm@latest

# Install latest npm
RUN npm install -g npm@latest

# Install Redis from source
ENV REDIS_VERSION 3.0.7
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-3.0.7.tar.gz
ENV REDIS_DOWNLOAD_SHA1 e56b4b7e033ae8dbf311f9191cf6fdf3ae974d1c

RUN buildDeps='gcc libc6-dev make' \
    && set -x \
    && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O redis.tar.gz "$REDIS_DOWNLOAD_URL" \
    && echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
    && mkdir -p /usr/src/redis \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && rm redis.tar.gz \
    && make -C /usr/src/redis \
    && make -C /usr/src/redis install \
    && rm -r /usr/src/redis

# VIRTUALENV - Set up virtualenv and virtualenvwrapper, can use whichever you prefer
RUN pip install virtualenv virtualenvwrapper

EXPOSE 80 443 3000 3001 8080

CMD bash
