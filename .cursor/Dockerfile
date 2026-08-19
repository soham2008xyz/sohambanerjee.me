FROM ruby:3.2.6-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates \
        gnupg \
        build-essential \
        libssl-dev \
        libreadline-dev \
        zlib1g-dev \
        libyaml-dev \
        libffi-dev \
        libgdbm-dev \
        libncurses5-dev \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && gem install bundler --no-document

RUN useradd -m -s /bin/bash ubuntu

USER ubuntu
WORKDIR /home/ubuntu
