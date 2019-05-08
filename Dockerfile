FROM alpine:3.9
LABEL maintainer "james@ustc.edu.cn"

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN echo '' > /etc/apk/repositories && \
    echo "http://mirrors.ustc.edu.cn/alpine/v3.9/main"         >> /etc/apk/repositories && \
    echo "http://mirrors.ustc.edu.cn/alpine/v3.9/community"    >> /etc/apk/repositories && \
    echo "202.38.95.110     mirrors.ustc.edu.cn"               >> /etc/hosts && \
    echo "Asia/Shanghai" > /etc/timezone

ADD httptest/httptest.c /httptest/httptest.c

RUN apk --no-cache add gnupg haveged tini bash curl openssl gcc openssl-dev libgcc libstdc++ linux-headers musl-dev && \
  gcc -o httptest/httptest httptest/httptest.c -lssl -lcrypto && \
  apk del gcc openssl-dev libgcc libstdc++ linux-headers musl-dev

COPY urls.txt /
COPY run.docker.sh /run.sh
COPY runhttpcheck.sh /

ENTRYPOINT ["/sbin/tini", "--", "/run.sh"]

