#!/bin/bash

LESSON_PATH=$1

# Define variables
LESSON_NAME=$(basename "$LESSON_PATH")
VOLUME_NAME="workbench-lessons"
TARGET_DIR="//home/rstudio/lessons"
TEMP_CONTAINER="temp_copy_container"

# Ensure the source directory exists
if [ ! -d "$LESSON_PATH" ]; then
  echo "Error: Source directory '$LESSON_PATH' does not exist."
  exit 1
fi

# Create the volume if it does not exist
if ! docker volume ls | grep -q "$VOLUME_NAME"; then
  echo "Creating Docker volume: $VOLUME_NAME"
  docker volume create "$VOLUME_NAME"
fi

# Start a temporary container with the volume
echo "Starting temporary container..."
docker run -d --name "$TEMP_CONTAINER" -v "$VOLUME_NAME:$TARGET_DIR" alpine sleep infinity

# Copy data from the host to the container's volume
echo "Copying files to Docker volume..."
docker cp "$LESSON_PATH/." "$TEMP_CONTAINER:$TARGET_DIR/$LESSON_NAME"

# Change ownership inside the container
echo "Fixing file permissions..."
docker exec "$TEMP_CONTAINER" chown -R 1000:1000 "$TARGET_DIR/$LESSON_NAME"

# Stop and remove the temporary container
echo "Cleaning up..."
docker stop "$TEMP_CONTAINER" > /dev/null
docker rm "$TEMP_CONTAINER" > /dev/null

echo "Data successfully copied to volume '$VOLUME_NAME'."

docker run --rm -v "$VOLUME_NAME:$TARGET_DIR" alpine ls -l "$TARGET_DIR"
