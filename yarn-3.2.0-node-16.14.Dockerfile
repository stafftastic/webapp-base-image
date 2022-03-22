FROM node:16.14-alpine

RUN corepack enable \
    && yarn set version 3.2.0
