FROM ubuntu:14.04

RUN apt-get update

RUN apt-get install -y gcc \
                       make \
                       libpulse-dev \
                       libasound2-dev \
                       libmad0-dev \
                       libopusfile-dev \
                       libvorbis-dev

ADD . /vorbis2alsa/
WORKDIR /vorbis2alsa/

RUN make
