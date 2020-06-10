FROM ubuntu

RUN apt-get update \
     && apt-get install -y wget software-properties-common \
     && rm -rf /var/lib/apt/lists/*

WORKDIR "/root"

RUN add-apt-repository -y ppa:ethereum/ethereum

ARG binary
RUN apt-get update \
     && apt-get install -y ethereum

ENV nodekey=""
CMD exec bootnode -nodekey $nodekey

EXPOSE 30301/udp
EXPOSE 30303/udp