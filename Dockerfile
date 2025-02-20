# use tidyverse image to get devtools etc
FROM rocker/tidyverse:latest

SHELL ["/bin/bash", "-c"]

# update and install base build tools
RUN sudo apt-get update
RUN sudo apt-get install -y git autoconf build-essential

# Install system dependencies
RUN apt-get install -y \
    jq \
    zlib1g-dev \
    libxslt1-dev \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    pandoc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# setup base renv for lessons that want to use it
RUN R -e 'install.packages(c("renv", "remotes", "httpuv"), repos = c(CRAN = "https://cloud.r-project.org"))'

ARG SANDPAPER_VER
ARG VARNISH_VER
ARG PEGBOARD_VER

# Convert ARG to ENV so they persist inside the container
ENV SANDPAPER_VER=${SANDPAPER_VER}
ENV VARNISH_VER=${VARNISH_VER}
ENV PEGBOARD_VER=${PEGBOARD_VER}

COPY scripts/* /home/rstudio/.workbench/
RUN chmod +x /home/rstudio/.workbench/*
RUN source /home/rstudio/.workbench/init_env.sh

RUN Rscript /home/rstudio/.workbench/deps.R

# clean up
RUN rm -rf /tmp/downloaded_packages
