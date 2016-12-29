FROM centos:7

MAINTAINER Philip Jay <phil@jay.id.au>

ENV TZ Australia/Melbourne

RUN yum install -y epel-release && \
    yum update -y && \
    yum clean all

RUN yum install -y \
            libuuid \
            libxslt \
            uriparser \
            jansson && \
    yum clean all

RUN useradd -r -d / -s /sbin/nologin asterisk
ADD tgz/asterisk.tgz /

USER asterisk

VOLUME /etc/asterisk

CMD /usr/sbin/asterisk -f -vvv
