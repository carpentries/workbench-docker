#!/bin/bash

LESSONS_DIR="//home/rstudio/lessons"
PORT=8787
WORKBENCH_TAG="latest"

while getopts 'l:p:t:h' opt; do
  case "$opt" in
    l)
      LESSONS_DIR="${OPTARG}"
      ;;

    p)
      PORT=${OPTARG}
      ;;

    t)
      WORKBENCH_TAG="${OPTARG}"
      ;;

    ?|h)
      echo "Usage: $(basename $0) [-l <lesson_dir>] [-p <port>] [-t <container_version>] [-h]"
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

# pull if none exists
img=$(docker image ls -q carpentries/workbench-docker:$WORKBENCH_TAG)
if [ -z $img ]; then
  echo "No workbench-docker image found. Pulling $WORKBENCH_TAG ..."
  docker pull carpentries/workbench-docker:$WORKBENCH_TAG
fi

# stop all running carpentries-workbench containers
echo "Stopping all running carpentries-workbench containers ..."
docker stop $(docker ps -a | grep carpentries-workbench | cut -d " " -f 1)

# check if a container exists
docker ps -a --format 'table {{.Image}}' | grep workbench-docker:$WORKBENCH_TAG
if [ $? -eq 1 ]; then
  # no existing containers exists so start a new one
  echo "Starting carpentries-workbench-$WORKBENCH_TAG container ..."
  docker run -d -it --name carpentries-workbench-$WORKBENCH_TAG --user rstudio -p $PORT:8787 -v ~/.ssh://home/rstudio/.ssh:ro -v ~/.gnupg://home/rstudio/.gnupg -v ~/.gitconfig://home/rstudio/.gitconfig -v workbench-lessons:$LESSONS_DIR -e DISABLE_AUTH=true carpentries/workbench-docker:$WORKBENCH_TAG //home/rstudio/start.sh

  echo "Open http://localhost:$PORT in your web browser."
else
  echo "Starting carpentries-workbench-$WORKBENCH_TAG container ..."
  docker start carpentries-workbench-$WORKBENCH_TAG

  echo "Open http://localhost:$PORT in your web browser."
fi
