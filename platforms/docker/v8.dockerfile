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
    libc++-dev \
    curl \
    git

# Build script should define these args
ARG SRC_DIR

# These args do not need to be defined, but can be used for convenience in the Dockerfile
ARG WORK_DIR=/plv8

ADD ${SRC_DIR}/Makefile.v8 ${WORK_DIR}/

ARG USE_ICU=1

#RUN --mount=id=v8-cache,type=cache,target=/plv8/build mkdir -p /plv8/build \
#	&& cd /plv8 \
#	&& { test $USE_ICU -eq 1 && { make USE_ICU=1 -f Makefile.v8 v8 ; } || { make -f Makefile.v8 ; } ; }

RUN --mount=id=v8-cache,type=cache,target=/plv8/build mkdir -p /plv8/build \
	&& cd /plv8 \
	&& if test $USE_ICU -eq 1 ; then make USE_ICU=1 -f Makefile.v8 v8 ; else make -f Makefile.v8 ; fi

RUN --mount=id=v8-cache,type=cache,target=/plv8/build echo \
		&& mkdir -p /plv8/out/v8/out.gn \
		&& cp -r /plv8/build/v8/out.gn/. /plv8/out/v8/out.gn/ \
		&& mkdir -p /plv8/out/v8/third_party/icu/common \
		&& cp -r /plv8/build/v8/third_party/icu/common/. /plv8/out/v8/third_party/icu/common/ \
		&& mkdir -p /plv8/out/v8/include \
		&& cp -r /plv8/build/v8/include/. /plv8/out/v8/include/ 


WORKDIR ${WORK_DIR}

CMD ["/bin/bash"]

