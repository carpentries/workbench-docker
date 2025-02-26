#!/bin/bash

# Mark Repository as Safe
git config --global --add safe.directory /home/rstudio/lesson

su - rstudio

echo "Running as $(whoami) $(id -u) $(id -g)"
ls -lAh /home/rstudio/lesson

cd /home/rstudio/lesson

# run setup
Rscript /home/rstudio/.workbench/run_tests.R
