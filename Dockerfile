FROM rust

ARG TONOS_CLI_VERSION=v0.6.0

WORKDIR /opt/tonos-cli

RUN wget http://sdkbinaries.tonlabs.io/tonos-cli-0_6_0-linux.zip && \
  unzip tonos-cli-0_6_0-linux.zip && mv tonos-cli /usr/local/bin && rm tonos-cli-0_6_0-linux.zip

RUN curl -sL https://deb.nodesource.com/setup_15.x | bash - && \
  apt-get install -y nodejs xxd

RUN npm install -g halva-cli

ENTRYPOINT ["tonos-cli"]
