FROM ubuntu:xenial

RUN apt-get update && apt-get install -y \
  cron \
  bash-completion \
  build-essential \
  cmake \
  libcurl3  \
  libcurl3-openssl-dev  \
  libssl-dev \
  libxml2 \
  libxml2-dev  \
  pkg-config \
  ca-certificates \
  xclip \
  git \
  asciidoc \
  xsltproc \
  man && \
  git clone https://github.com/lastpass/lastpass-cli.git && \
  cd lastpass-cli && \
  make && \
  make install && \
  make install-doc

# Set the entry point
ENTRYPOINT ["/init"]

VOLUME /conf

# Install services
COPY services /etc/services.d

COPY backup.sh /backup.sh

# Install init.sh as init script
COPY init.sh /etc/cont-init.d/

# Download and extract s6 init
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.19.1.1/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

