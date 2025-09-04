#!/bin/bash
export GPG_TTY=$(tty)

LESSONS_DIR="//home/rstudio/lessons"

echo "Adding git safe directories..."

for d in $LESSONS_DIR/*/ ; do
  git config --add safe.directory "$d"
done

echo "Using env..."
env

echo "Initialising the RStudio instance..."
sudo -E /init
