#!/bin/bash

# Mark Repository as Safe
git config --global --add safe.directory /home/rstudio/lesson

ls -lAh /home/rstudio/lesson

# run setup
Rscript /home/rstudio/.workbench/run_tests.R
