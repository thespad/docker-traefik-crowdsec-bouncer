# syntax=docker/dockerfile:1

# Building bouncer
FROM docker.io/golang:1.20-alpine as build-env

RUN apk add git && \
  git clone https://github.com/thespad/traefik-crowdsec-bouncer /go/src/app

WORKDIR /go/src/app

RUN go get -d -v ./...

RUN go build -o /go/bin/bouncer

FROM ghcr.io/linuxserver/baseimage-alpine:3.17

# set version label
ARG BUILD_DATE
ARG VERSION
ARG APP_VERSION
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"
LABEL org.opencontainers.image.source="https://github.com/thespad/docker-traefik-crowdsec-bouncer"
LABEL org.opencontainers.image.url="https://github.com/thespad/docker-traefik-crowdsec-bouncer"
LABEL org.opencontainers.image.description="An HTTP service to verify requests and bounce them according to decisions made by CrowdSec"

COPY --from=build-env /go/bin/bouncer /app

COPY /root /

EXPOSE 8080
