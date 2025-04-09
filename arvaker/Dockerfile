FROM ubuntu:24.04

RUN apt update -qq \
  && apt install -y llvm clang git build-essential

WORKDIR /Odin-install
RUN git clone https://github.com/odin-lang/Odin.git /Odin-install \
  && git checkout dev-2025-03 \
  && make

RUN mkdir /opt/Odin \
  && cp -R ./base ./core ./shared ./vendor ./odin /opt/Odin/
WORKDIR /

RUN rm -rf /Odin-install

ENV PATH="/opt/Odin:${PATH}"


