# syntax = docker/dockerfile:experimental

ARG PG_VERSION=11.5
ARG PLV8_VERSION=r3.0alpha
ARG AUTOV8_VERSION=branch-heads/7.7

FROM postgres:${PG_VERSION}

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

ARG SRC_DIR
ARG WORK_DIR=/plv8

ADD ${SRC_DIR}/. ${WORK_DIR}/

#COPY --from=plv8:build-v8 /plv8/build/v8/out.gn/x64.release.sample/obj /plv8/build/v8/out.gn/x64.release.sample/obj
#COPY --from=plv8:build-v8 /plv8/build/v8/out.gn/x64.release.sample/obj/third_party/icu /plv8/build/v8/out.gn/x64.release.sample/obj/third_party/icu
#COPY --from=plv8:build-v8 /plv8/build/v8/third_party/icu/common/icudtl.dat /plv8/build/v8/third_party/icu/common/icudtl.dat

ARG USE_ICU=1

RUN mkdir -p /plv8/build/v8/out.gn
COPY --from=plv8:build-v8 /plv8/out/v8/out.gn /plv8/build/v8/out.gn
COPY --from=plv8:build-v8 /plv8/out/v8/include /plv8/build/v8/include
COPY --from=plv8:build-v8 /plv8/out/v8/third_party/icu/common /plv8/build/v8/third_party/icu/common
RUN rm /plv8/Makefile.v8 && touch /plv8/Makefile.v8 

WORKDIR ${WORK_DIR}

RUN if test $USE_ICU -eq 1 ; then make USE_ICU=1 static ; else make ; fi

CMD ["/bin/bash"]
