# use tidyverse image to get devtools etc
FROM rocker/rstudio:latest

LABEL "source"="https://github.com/carpentries/workbench-docker/Dockerfile"
LABEL "maintainer.name"="Robert Davey"
LABEL "maintainer.email"="robertdavey@carpentries.org"

SHELL ["/bin/bash", "-c"]

WORKDIR /home/rstudio

# copy over all scripts
COPY .Renviron /home/rstudio/.Renviron
RUN chown -R rstudio:rstudio /home/rstudio/.Renviron

COPY .env /home/rstudio/.env
RUN chmod +rx /home/rstudio/.env && \
    chown rstudio:rstudio /home/rstudio/.env

COPY local_entrypoint.sh .
RUN chmod +x local_entrypoint.sh && \
    chown rstudio:rstudio local_entrypoint.sh

COPY start.sh .
RUN chmod +x start.sh && \
    chown rstudio:rstudio start.sh

COPY scripts/* /home/rstudio/.workbench/
RUN chmod +x /home/rstudio/.workbench/* && \
    chown -R rstudio:rstudio /home/rstudio/.workbench && \
    source /home/rstudio/.workbench/init_env.sh

# update and install base build tools
RUN apt-get update && apt-get install -y git autoconf build-essential software-properties-common

RUN (type -p wget >/dev/null || (apt install wget -y)) \
	&& mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&&  mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& apt update

# Install system dependencies
RUN apt-get install -y \
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
    && apt-get clean all \
    && apt-get purge \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "rstudio ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

# setup base renv for lessons that want to use it
RUN R -e 'install.packages(c("renv", "remotes", "httpuv", "httr", "gh", "yaml"), repos = c(CRAN = "https://cloud.r-project.org"))'

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
RUN Rscript /home/rstudio/.workbench/deps.R

# clean up
RUN rm -rf /tmp/downloaded_packages
