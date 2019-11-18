FROM alpine:3.7 as builder

ENV BEANSTALKD_VERSION="1.11"

RUN apk update \
    && apk upgrade --force \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        make \
        musl-dev \
    && cd /tmp \
    && wget -O "beanstalkd-${BEANSTALKD_VERSION}.tar.gz" \
        "https://github.com/kr/beanstalkd/archive/v${BEANSTALKD_VERSION}.tar.gz" \
    && tar -xzf "beanstalkd-${BEANSTALKD_VERSION}.tar.gz" \
    && cd "beanstalkd-${BEANSTALKD_VERSION}" \
    && sed -i "s|#include <sys/fcntl.h>|#include <fcntl.h>|g" sd-daemon.c \
    && make || return 1 \
    && make PREFIX=/usr install \
    && beanstalkd -v

FROM alpine:3.7
COPY --from=builder /usr/bin/beanstalkd /usr/bin/beanstalkd

EXPOSE 11300
ENTRYPOINT ["/usr/bin/beanstalkd"]
