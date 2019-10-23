# syntax = docker/dockerfile:experimental

# User should define these args
ARG PG_VERSION=11.5
ARG PLV8_VERSION=r3.0alpha

FROM postgres:${PG_VERSION} AS build_v8

# Build script should define these args
ARG SRC_DIR

# These args do not need to be defined, but can be used for convenience in the Dockerfile
ARG WORK_DIR=/plv8

RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
    > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt apt-get update -qq \
    && apt-get install -yy \
    postgresql-server-dev-11 \
    gcc \
    make \
    g++ \
    lib++-dev \
    curl \
    git


ADD ${SRC_DIR}/. ${WORK_DIR}/

# WORKDIR ${WORK_DIR}

CMD ["/bin/bash"]



# RUN --mount=type=cache,target=${WORK_DIR}/build make v8

# FROM postgres:${PG_VERSION} AS build_plv8

# ADD ${SRC_DIR} ${WORK_DIR}

