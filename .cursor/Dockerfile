FROM ruby:3.2.6-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        build-essential \
        libssl-dev \
        libreadline-dev \
        zlib1g-dev \
        libyaml-dev \
        libffi-dev \
        libgdbm-dev \
        libncurses5-dev \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && gem install bundler --no-document

RUN useradd -m -s /bin/bash ubuntu

USER ubuntu
WORKDIR /home/ubuntu
