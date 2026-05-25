ARG R_VERSION=latest
FROM rocker/rstudio:${R_VERSION}

LABEL "source"="https://github.com/carpentries/workbench-docker/Dockerfile"
LABEL "maintainer.name"="Robert Davey"
LABEL "maintainer.email"="robertdavey@carpentries.org"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /home/rstudio

# copy over all scripts
COPY .Renviron /home/rstudio/.Renviron
RUN <<RENVR
    chown -R rstudio:rstudio /home/rstudio/.Renviron
RENVR

COPY .env /home/rstudio/.env
RUN <<DOTENV
    chmod +rx /home/rstudio/.env
    chown rstudio:rstudio /home/rstudio/.env
DOTENV

COPY local_entrypoint.sh .
RUN <<LENTRY
    chmod +x local_entrypoint.sh
    chown rstudio:rstudio local_entrypoint.sh
LENTRY

COPY start.sh .
RUN <<START
    chmod +x start.sh
    chown rstudio:rstudio start.sh
START

COPY scripts/* /home/rstudio/.workbench/
RUN <<INITENV
    chmod +x /home/rstudio/.workbench/*
    chown -R rstudio:rstudio /home/rstudio/.workbench
    source /home/rstudio/.workbench/init_env.sh
INITENV

# update and install base build tools
RUN <<BUILDDEPS
    apt-get update
    apt-get install -y git autoconf build-essential software-properties-common
BUILDDEPS

RUN <<APTSRC
    (type -p wget >/dev/null || (apt install wget -y))
	mkdir -p -m 755 /etc/apt/keyrings
	out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg
	cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
	chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
	mkdir -p -m 755 /etc/apt/sources.list.d
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
	apt update
APTSRC

# Install system dependencies
RUN <<APTGET
    apt-get install -y \
    jq \
    zlib1g-dev \
    libcurl4-openssl-dev \
    libfontconfig-dev \
    libfreetype-dev \
    libfribidi-dev \
    libharfbuzz-dev \
    libicu-dev \
    libgit2-dev \
    libjpeg-turbo8-dev \
    libpng-dev \
    libuv1-dev \
    libxml2-dev \
    libxslt1-dev \
    libssl-dev \
    libtiff-dev \
    libx11-dev \
    libgdal-dev \
    libcairo2-dev \
    libglpk-dev \
    libmagick++-dev \
    libnode-dev \
    libudunits2-dev \
    gdal-bin \
    xdg-utils \
    pngquant \
    pandoc \
    curl \
    ssh \
    nano \
    gh \
    cmake \
    rsync

    apt-get clean all
    apt-get purge
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
APTGET

RUN <<AWSCLI
    arch=$(arch)
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip ./aws
    aws --version
AWSCLI

RUN echo "rstudio ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

# setup base renv for lessons that want to use it
RUN R -e 'install.packages(c("renv", "remotes", "httpuv", "httr", "cffr", "gh", "yaml"), repos = c(CRAN = "https://cloud.r-project.org"))'

# enable build args
ARG SANDPAPER_REF
ARG VARNISH_REF
ARG PEGBOARD_REF
ARG NO_LATEST

# Convert ARG to ENV so they persist inside the container
ENV SANDPAPER_REF=${SANDPAPER_REF}
ENV VARNISH_REF=${VARNISH_REF}
ENV PEGBOARD_REF=${PEGBOARD_REF}
ENV NO_LATEST=${NO_LATEST}

# install dependencies and workbench packages
RUN <<DEPS
    Rscript /home/rstudio/.workbench/deps.R
DEPS

# clean up
RUN rm -rf /tmp/downloaded_packages
