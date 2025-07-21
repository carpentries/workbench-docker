#!/bin/bash
export GPG_TTY=$(tty)

# Mark Repository as Safe
git config --global --add safe.directory /home/rstudio/lesson

echo "Running as $(whoami) $(id -u) $(id -g)"
ls -lAh /home/rstudio/lesson

cd /home/rstudio/lesson

# run setup
Rscript /home/rstudio/.workbench/ci_run_tests.R
