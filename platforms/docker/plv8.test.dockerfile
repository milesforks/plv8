# syntax = docker/dockerfile:experimental

ARG PG_VERSION=11.5
ARG PLV8_VERSION=r3.0alpha

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

RUN mkdir -p /var/lib/postgresql/data \
	&& chown -R postgres:postgres /var/lib/postgresql/data \
	&& echo "local   all         postgres                          trust" > /etc/postgresql/pg_hba.conf \
	&& echo "local   all         all                               trust" >> /etc/postgresql/pg_hba.conf \
   	&& echo "host    all         all         127.0.0.1/32          trust" >> /etc/postgresql/pg_hba.conf \
    	&& echo "host    all         all         ::1/128               trust" >> /etc/postgresql/pg_hba.conf \
	&& echo \ 
	&& echo "plv8.icu_data='/plv8/icudtl.dat" > /etc/postgresql/postgresql.conf

ADD ${SRC_DIR}/. ${WORK_DIR}/

RUN mkdir -p /plv8

COPY --from=plv8:build-plv8 /plv8/*.so /plv8/*.sql /plv8/*.control /plv8/*.common /plv8/

COPY --from=plv8:build-plv8 /plv8/plv8-3.0alpha.so /plv8/

WORKDIR /plv8

#RUN touch stamp.cc && make -f Makefile.shared USE_PGXS=1 install 

CMD ["/bin/bash"]
