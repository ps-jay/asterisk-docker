FROM centos:7

MAINTAINER Philip Jay <phil@jay.id.au>

ENV TZ Australia/Melbourne

RUN yum install -y epel-release && yum update -y && \
    yum install -y \
        kernel-headers kernel-devel \
        gcc gcc-c++ cpp \
        ncurses ncurses-devel \
        libxml2 libxml2-devel \
        sqlite sqlite-devel \
        openssl-devel \
        newt-devel \
        libuuid-devel \
        net-snmp-devel \
        jansson-devel \
        xinetd \
        tar \
        make

ADD  menuselect/* /tmp/source/
RUN  useradd asterisk && \
     chown -R asterisk:asterisk /tmp/source/
USER asterisk

RUN mkdir -p /tmp/source /tmp/build && \
    curl -sSf \
         -o /tmp/asterisk.tar.gz \
         -L http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz && \
    tar -xzf /tmp/asterisk.tar.gz \
        -C /tmp/source \
        --strip-components=1

WORKDIR /tmp/source

RUN ./configure \
    --prefix=/tmp/build \
    --libdir=/tmp/build/usr/lib64

RUN time make -j `nproc`

RUN make install

WORKDIR /tmp/build
RUN     tar -czf /tmp/asterisk.tgz . && \
        cd /tmp && echo "SHA1: `sha1sum asterisk.tgz`"

WORKDIR /
CMD sleep infinity
