# FROM node:8.11.4-alpine
FROM alpine:edge

ENV PM2_VERSION=3.3.1
ENV NPM_CONFIG_LOGLEVEL warn
RUN apk add --update \
  python \
  python-dev \
  py-pip \
  build-base \
  npm \
  && pip install virtualenv \
  && rm -rf /var/cache/apk/*
RUN npm config set registry https://registry.npm.taobao.org && npm install -g pm2@$PM2_VERSION 
ADD app.tar.gz /meteor-app 
RUN cd  /meteor-app/bundle/programs/server \ && npm install --production
RUN cd  /meteor-app/bundle \ && pm2 completion >> ~/.bashrc &&  SHELL=/bin/bash pm2 completion install
