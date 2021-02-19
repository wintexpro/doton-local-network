FROM rust

ARG TONOS_CLI_VERSION=v0.6.0

WORKDIR /opt/tonos-cli

RUN cargo install \
    --git https://github.com/tonlabs/tonos-cli.git \
    --tag $TONOS_CLI_VERSION

RUN curl -sL https://deb.nodesource.com/setup_15.x | bash - && \
  apt-get install -y nodejs xxd

RUN npm install -g halva-cli

ENTRYPOINT ["tonos-cli"]
