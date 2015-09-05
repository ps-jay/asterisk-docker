FROM centos:7

MAINTAINER Philip Jay <phil@jay.id.au>

ENV TZ Australia/Melbourne

RUN yum install -y epel-release && \
    yum update -y && \
    yum install -y \
        kernel-headers kernel-devel \
        gcc gcc-c++ cpp \
        make \
        tar && \
    yum clean all
RUN yum install -y \
        ncurses-devel \
        libxml2-devel \
        openssl-devel \
        newt-devel \
        libuuid-devel \
        sqlite-devel \
        jansson-devel && \
    yum clean all

ADD  menuselect/* /tmp/source/
RUN  useradd -r -d / -s /sbin/nologin asterisk && \
     chown -R asterisk:asterisk /tmp/source/
USER asterisk

RUN mkdir -p /tmp/source /tmp/build && \
    curl -sSf \
         -o /tmp/asterisk.tar.gz \
         -L http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz && \
    tar -xzf /tmp/asterisk.tar.gz \
        -C /tmp/source \
        --strip-components=1 && \
    rm -v /tmp/asterisk.tar.gz

WORKDIR /tmp/source

RUN ./configure \
    --libdir=/usr/lib64

RUN make -j `nproc`

RUN make install DESTDIR=/tmp/build

WORKDIR /tmp/build

RUN sed -i -e 's/# MAXFILES=/MAXFILES=/' usr/sbin/safe_asterisk && \
    rm -rf etc && \
    tar -czf /tmp/asterisk.tgz . && \
    cd /tmp && echo "SHA1: `sha1sum asterisk.tgz`"

WORKDIR /
CMD sleep infinity
