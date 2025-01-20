FROM rocker/rstudio:latest

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
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

# copy repo config and anything else
COPY scripts/profile.sh /home/rstudio/workbench/profile.sh
RUN chown rstudio:rstudio /home/rstudio/workbench/profile.sh
RUN chmod a+x /home/rstudio/workbench/profile.sh
RUN /home/rstudio/workbench/profile.sh

# clean up
RUN rm -rf /tmp/downloaded_packages

# install workbench deps
RUN R -e "install.packages(c('sandpaper', 'varnish', 'pegboard', 'httpuv'))"
