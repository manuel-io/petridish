FROM ubuntu:14.04

RUN apt-get update

RUN apt-get install -y gcc-arm-none-eabi \
                       qemu \
                       make \
                       xvfb

ADD . /integrator/
WORKDIR /integrator/

RUN make
