# syntax = docker/dockerfile:experimental

# User should define these args
ARG PG_VERSION=11.5
ARG PLV8_VERSION=r3.0alpha
ARG AUTOV8_VERSION=branch-heads/7.7

FROM postgres:${PG_VERSION} AS build_v8

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

# Build script should define these args
ARG SRC_DIR

# These args do not need to be defined, but can be used for convenience in the Dockerfile
ARG WORK_DIR=/plv8

ADD ${SRC_DIR}/Makefile.v8 ${WORK_DIR}/

RUN --mount=id=v8-cache,type=cache,target=/plv8/build mkdir -p /plv8/build && cd /plv8 && make -f Makefile.v8 v8

RUN --mount=id=v8-cache,type=cache,target=/plv8/build mkdir -p /plv8/out/v8/out.gn \
	&& cp -R /plv8/build/v8/out.gn /plv8/out/v8/out.gn \
	&& mkdir -p /plv8/out/v8/third_party/icu \
	&& cp -R /plv8/build/v8/third_party/icu /plv8/out/v8/third_party/icu

WORKDIR ${WORK_DIR}

CMD ["/bin/bash"]

