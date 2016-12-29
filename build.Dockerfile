FROM centos:7

MAINTAINER Philip Jay <phil@jay.id.au>

ENV  TZ Australia/Melbourne

RUN  yum install -y epel-release
RUN  yum update -y
RUN  yum install -y \
             kernel-headers kernel-devel \
             gcc gcc-c++ cpp \
             make \
             tar
RUN  yum install -y \
             ncurses-devel \
             libxml2-devel \
             openssl-devel \
             newt-devel \
             libuuid-devel \
             sqlite-devel \
             uriparser-devel \
             libxslt-devel \
             jansson-devel

RUN  mkdir -p /tmp/source /tmp/build
RUN  useradd -r -d / -s /sbin/nologin asterisk
RUN  chown -R asterisk:asterisk /tmp/source /tmp/build
USER asterisk

RUN  curl -sSf \
          -o /tmp/asterisk.tar.gz \
          -L http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz
RUN  tar -xzf /tmp/asterisk.tar.gz \
         -C /tmp/source \
         --strip-components=1

WORKDIR /tmp/source

RUN  ./configure \
         --libdir=/usr/lib64

# Only build what we want to
RUN  make menuselect
RUN  menuselect/menuselect --disable-all menuselect.makeopts
RUN  menuselect/menuselect \
         --enable-category MENUSELECT_BRIDGES \
         --enable-category MENUSELECT_FORMATS \
         --enable LOADABLE_MODULES \
         --enable app_confbridge \
         --enable app_dial \
         --enable app_echo \
         --enable app_exec \
         --enable app_playback \
         --enable app_playtones \
         --enable app_read \
         --enable app_readexten \
         --enable app_sayunixtime \
         --enable app_senddtmf \
         --enable app_sendtext \
         --enable app_softhangup \
         --enable app_stack \
         --enable app_transfer \
         --enable app_verbose \
         --enable chan_bridge_media \
         --enable chan_sip \
         --enable codec_a_mu \
         --enable codec_adpcm \
         --enable codec_alaw \
         --enable codec_g722 \
         --enable codec_g726 \
         --enable codec_ulaw \
         --enable pbx_config \
         --enable res_agi \
         --enable res_crypto \
         --enable res_http_websocket \
         --enable res_monitor \
         --enable res_musiconhold \
         --enable res_rtp_asterisk \
         --enable res_timing_timerfd \
         --enable CORE-SOUNDS-EN_AU-ALAW \
         --enable CORE-SOUNDS-EN_AU-ULAW \
         menuselect.makeopts

RUN  time make -j `nproc`

RUN  time make install DESTDIR=/tmp/build

WORKDIR /tmp/build
RUN  sed -i -e 's/# MAXFILES=/MAXFILES=/' usr/sbin/safe_asterisk
RUN  rm -rf etc

WORKDIR /tmp/build/var/lib/asterisk/sounds
RUN  ln -s en_AU en

WORKDIR /tmp/build
RUN  tar -czf /tmp/asterisk.tgz .

WORKDIR /tmp
RUN  echo "Created tgz SHA1: `sha1sum asterisk.tgz`"
