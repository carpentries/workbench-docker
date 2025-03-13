#!/bin/bash
export LESSON_NAME="$1"

echo "Adding git safe directory..."

cd /home/rstudio/lessons/$LESSON_NAME
git config --add safe.directory /home/rstudio/lessons/$LESSON_NAME

echo "Using env..."
env

echo "Initialising the RStudio instance..."
sudo -E /init
