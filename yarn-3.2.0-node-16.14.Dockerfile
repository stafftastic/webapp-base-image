FROM node:16.14-alpine

RUN apk add --no-cache \
	libstdc++ \
	curl \
	gcompat

RUN corepack enable \
    && yarn set version 3.2.0

WORKDIR /app
