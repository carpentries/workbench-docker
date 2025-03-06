#!/bin/bash
export LESSON_NAME="$1"

echo "Using env..."
env

echo "Initialising the RStudio instance..."
sudo -E /init
