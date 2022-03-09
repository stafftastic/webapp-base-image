FROM node:16.13-alpine

RUN corepack enable \
    && yarn set version 3.2.0
