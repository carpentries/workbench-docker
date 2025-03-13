#!/bin/bash

LESSON_NAME="$1"
LESSONS_DIR="/home/rstudio/lessons"
NAMED_LESSON_DIR="$LESSONS_DIR/$LESSON_NAME"

# check lesson exists in named volume
docker run --rm -v "workbench-lessons:/home/rstudio/lessons" alpine ls -l $NAMED_LESSON_DIR
if [ $? -ne 0 ]; then
  echo "Error: Lesson '$LESSON_NAME' not found in named volume 'workbench-lessons'."
  echo "Options are:"
  docker run --rm -v "workbench-lessons:/home/rstudio/lessons" alpine ls $LESSONS_DIR
  exit 1
fi

# stop the existing workbench_rstudio container
docker stop carpentries-workbench

docker rm carpentries-workbench

# start the workbench_rstudio container
docker run -it --name carpentries-workbench --user rstudio -p 8787:8787 -v ~/.ssh:/home/rstudio/.ssh:ro -v ~/.gitconfig:/home/rstudio/.gitconfig -v workbench-lessons:/home/rstudio/lessons -e DISABLE_AUTH=true carpentries/workbench-docker:latest /home/rstudio/start.sh $LESSON_NAME
