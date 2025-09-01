# use tidyverse image to get devtools etc
FROM rocker/rstudio:latest

LABEL "source"="https://github.com/carpentries/workbench-docker/Dockerfile"
LABEL "maintainer.name"="Robert Davey"
LABEL "maintainer.email"="robertdavey@carpentries.org"

SHELL ["/bin/bash", "-c"]

# update and install base build tools
RUN apt-get update
RUN apt-get install -y git autoconf build-essential

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
    xdg-utils \
    pngquant \
    pandoc \
    curl \
    ssh \
    nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "rstudio ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers

# setup base renv for lessons that want to use it
RUN R -e 'install.packages(c("renv", "remotes", "httpuv", "httr", "gh"), repos = c(CRAN = "https://cloud.r-project.org"))'

ARG SANDPAPER_VER
ARG VARNISH_VER
ARG PEGBOARD_VER

# Convert ARG to ENV so they persist inside the container
ENV SANDPAPER_VER=${SANDPAPER_VER}
ENV VARNISH_VER=${VARNISH_VER}
ENV PEGBOARD_VER=${PEGBOARD_VER}

WORKDIR /home/rstudio

COPY .Renviron /home/rstudio/.Renviron
RUN chown -R rstudio:rstudio /home/rstudio/.Renviron

COPY scripts/* /home/rstudio/.workbench/
RUN chmod +x /home/rstudio/.workbench/*
RUN chown -R rstudio:rstudio /home/rstudio/.workbench
RUN source /home/rstudio/.workbench/init_env.sh

RUN Rscript /home/rstudio/.workbench/deps.R

# clean up
RUN rm -rf /tmp/downloaded_packages

COPY .env /home/rstudio/.env
RUN chmod +rx /home/rstudio/.env
RUN chown rstudio:rstudio /home/rstudio/.env

COPY local_entrypoint.sh .
RUN chmod +x local_entrypoint.sh
RUN chown rstudio:rstudio local_entrypoint.sh

COPY start.sh .
RUN chmod +x start.sh
RUN chown rstudio:rstudio start.sh
