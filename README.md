# workbench-docker

A dockerised image of the Workbench dependencies required to build and serve lessons.

We currently provide two pre-built images:
- linux/amd64
- linux/arm64

## Current Known Issues

- Building images locally from scratch are likely not to work on Mac M* (M1, M2, etc), but should be fine on Mac Intel
- The container currently runs as root, so any files written to the mounted lesson volume will be owned on the host by root

## Prerequisites

1. Install Docker Desktop for [your operating system](https://docs.docker.com/compose/install/)
2. Open a terminal (bash, zsh, powershell, etc)
3. Then:

## Using the Workbench Image

### Pulling the latest pre-built image

Get the latest workbench image from dockerhub, and get its name:

```bash
docker pull carpentries/workbench-docker:latest
docker image list
```

The output should be similar to:

```bash
REPOSITORY                     TAG       IMAGE ID       CREATED      SIZE
carpentries/workbench-docker   latest    b816439d0469   6 days ago   2.89GB
```

### Running a container from the image

You can then run a container from the image, specifying a name for the container:

```bash
docker run --name wb carpentries/workbench-docker:latest
```

You will see some output:

```bash
[s6-init] making user provided files available at /var/run/s6/etc...exited 0.
[s6-init] ensuring user provided files have correct perms...exited 0.
[fix-attrs.d] applying ownership & permissions fixes...
[fix-attrs.d] done.
[cont-init.d] executing container initialization scripts...
[cont-init.d] 01_set_env: executing...
skipping /var/run/s6/container_environment/HOME
skipping /var/run/s6/container_environment/RSTUDIO_VERSION
[cont-init.d] 01_set_env: exited 0.
[cont-init.d] 02_userconf: executing...

tput: No value for $TERM and no -T specified
The password is set to at0AmooqueeQueup
If you want to set your own password, set the PASSWORD environment variable. e.g. run with:
docker run -e PASSWORD=<YOUR_PASS> -p 8787:8787 rocker/rstudio
tput: No value for $TERM and no -T specified

[cont-init.d] 02_userconf: exited 0.
[cont-init.d] done.
[services.d] starting services
[services.d] done.
```

This isn't particularly useful as your terminal now is running the container in `attached` mode and cannot accept new commands.

Hit Ctrl-C (Command-C) to stop the running container.

Remove the previous container using the name you provided before:

```bash
docker rm wb
```

Let's start the container in `detached` mode by adding the `-d` flag:

```bash
docker run --name wb -d carpentries/workbench-docker:latest
```

The command will return a hash of the running container. 

Once running, you can use `docker ps` to see what containers are running:

```bash
docker ps -l
```

You should see output like:

```bash
CONTAINER ID   IMAGE                                 COMMAND   CREATED          STATUS          PORTS      NAMES
63f1fd51f925   carpentries/workbench-docker:latest   "/init"   21 seconds ago   Up 20 seconds   8787/tcp   wb
```

To get just the ID and NAME for readability, use:

```bash
docker container list --all --format '{{.ID}} {{.Names}}'
```

Which will output:

```bash
63f1fd51f925 wb
```

Using the name in the NAMES column, in this case `wb`, execute a bash shell inside the container. The name of the container on your system may be different:

```bash
docker exec --user rstudio -it wb bash
rstudio@63f1fd51f925:~$
```

Congratulations! You're now inside your Workbench docker container!

You can now run an R session as normal. All Workbench packages are preinstalled for you:

```bash
R
```

Then

```r
library(sandpaper)
sandpaper::create_lesson()
...
```

Within the R session, you can create lessons from templates, build_lessons, etc.

To exit from the container, type `exit` at the bash prompt.

When you exit, your container is still running, and can be reused by re-running the docker exec command:

```bash
docker exec --user rstudio -it wb bash
```

### Removing a container

To remove a running container, first stop it:

```bash
docker stop wb
```

And then remove it:

```bash
docker rm wb
```

NOTE: any lesson content you develop will be stored within the container, and will be deleted if you delete the container.

To use a folder on your local host system as the lesson content, please read below.

Once a container is removed, you can start up a new fresh container from the same workbench docker image by following the first steps of this readme.

### Mounting a lesson to use with a pre-built image

If you already have a lesson on your local system that you want to use inside the container, you can mount your local lesson folder as a volume in the container.

However, we have to use `docker run` again, but with a few more options.

We can use the `-v` flag to mount a local folder on your system into the container.

In this case, we use `/home/your_user/lessons/shell-novice` as the example folder where your Carpentries lesson is stored:

```bash
docker run -it \
--name workbench_rstudio \
-p 8787:8787 \
-v /home/your_user/lessons/shell-novice:/home/rstudio/lesson \
--env-file .env \
-e USERID=$(id -u) \
-e GROUPID=$(id -g) \
carpentries/workbench-docker:latest \
/home/rstudio/start.sh
```

You can now open `localhost:8787` in your browser and you will be able to use a full RStudio server instance from within the container.

Note that changes made to the lesson from within this session will **affect your lesson on your host system**.

The options that can be modified are as follows:
* `name`: the name of the eventual workbench docker container
* `p`: the port on which you can access the RStudio server on your host system - **only** change the port number on the left of the colon, e.g. to use `localhost:8888` instead, supply `-p 8888:8787` as the option
* `v`: the local lesson folder to mount - **only** change the path on the left of the colon, e.g. to use `/home/foo/git-novice` as the lesson folder, supply `-v /home/foo/git-novice:/home/rstudio/lesson` as the option

Please leave all other options unchanged.

If you don't want to use RStudio Server, you can start an R session directly:

```bash
docker run --rm -it --name wb --user rstudio --env-file .env -v /home/your_user/lessons/shell-novice:/home/rstudio/lesson carpentries/workbench-docker:latest R
```

Then build or serve your lesson:

```r
library(sandpaper)
sandpaper::serve("/home/rstudio/lesson")
```

## Building the images yourself

### Clone this repository

Clone this repository into somewhere suitable, e.g. a `workbench` folder in your home directory:

```
cd ~
mkdir workbench
cd workbench
git clone git@github.com:carpentries/workbench-docker.git
```

### To build lessons locally

Clone a remote git lesson into somewhere suitable, e.g. a `lessons` folder in your home directory:

```
cd ~
mkdir lessons
cd lessons
git clone git@github.com:swcarpentry/shell-novice.git
```

Go into the workbench-docker folder, and run the image with the LESSON_PATH env variable:

```
cd ~/workbench/workbench-docker
LESSON_PATH=/home/your_user/lessons/shell-novice docker compose up workbench-local
```

This will build the container, and install any required packages including renv.lock dependencies.

It will also start a RStudio server inside the container that is accessible on your host system by opening a browser and going to:

`localhost:8787`

Your lesson will be available under the `/home/rstudio/lesson` folder inside the container.

## Rebuilding the image

If the container is already running, go to the `workbench-docker` folder and run `docker compose down`.

Then run `docker compose --build -d` to rebuild the image.

## Removing previous containers

You can use `docker container list --all` to list current containers. Find the name of the container you wish to remove.

Make sure the container is stopped by using `docker stop <container_name>`.

To remove an existing container, use `docker rm <container_name>`.

You can also use the Docker Desktop app to start, stop and delete containers, images and builds.

Please check the relevant [Docker Desktop documentation](https://docs.docker.com/desktop/).

## Adding extra dependencies

If you have any issues with this image, please email us on `infrastructure at carpentries.org` or head to the `#workbench` channel in our [Slack server](https://slack-invite.carpentries.org/).
