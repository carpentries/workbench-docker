#!/bin/bash
export GPG_TTY=$(tty)

LESSONS_DIR="/home/rstudio/lessons"

echo "Adding git safe directories..."

for d in $LESSONS_DIR/*/ ; do
  cd $d
  git config --unset-all safe.directory
  git config --add safe.directory "$d"
done

cd $LESSONS_DIR

echo "Using env..."
env

echo "Initialising the RStudio instance..."
sudo -E /init
