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

## Quick Start

```bash
# go home
cd ~

# get the latest workbench docker image
docker pull carpentries/workbench-docker:latest

# make a `lessons` folder in your home directory and clone in a lesson
mkdir ~/lessons
cd ~/lessons
git clone git@github.com:swcarpentry/shell-novice.git

# make a `workbench` folder in your home directory and clone in the workbench-docker repo
mkdir ~/workbench
cd ~/workbench
git clone git@github.com:carpentries/workbench-docker.git

# enter the `workbench-docker` folder, create the workbench-lessons named volume, and copy in the shell-novice content
cd workbench-docker
./scripts/setup_named_volume.sh ~/lessons/shell-novice

# start the workbench container
./scripts/run_workbench.sh shell-novice
```

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

## Building Workbench lessons

There are two ways to access lessons within the Workbench docker container:
- by using a named volume (**recommended**)
- by mounting the lesson directory directly into the container

### Using named volumes

Named volumes are like a virtual disk that you can use across different containers.

They're useful as they avoid permissions issues and other problems that can be present in some situations.

Therefore, we recommend creating a `workbench-lesson` named volume to store copies of the lessons you want to use.

#### Downloading the named volume creation script

If you have cloned the workbench-docker repository, the `scripts/` folder contains the `setup_named_volume.sh` script.

If you want to download the script only, instead of cloning the whole repo, use `wget` or `curl` to download the script into a suitable location, e.g.:

`wget https://raw.githubusercontent.com/carpentries/workbench-docker/refs/heads/main/scripts/setup_named_volume.sh`

#### Create a named volume using the provided script

The `setup_named_volume.sh` script creates a new named volume called `workbench-lessons`.

You can use this named volume to store multiple lessons as the whole lesson folder is copied inside it.

Provide the script with the absolute or relative path to the lesson you want to store inside the named volume:

```bash
cd scripts/
./setup_named_volume.sh /path/to/your/lesson
```

For a full example from scratch:

```bash
# make a `lessons` folder in your home directory and clone in a lesson
mkdir ~/lessons
cd ~/lessons
git clone git@github.com:datacarpentry/R-ecology-lesson.git

# make a `workbench` folder in your home directory and clone in the workbench-docker repo
cd ~
mkdir workbench
cd ~/workbench
git clone git@github.com:carpentries/workbench-docker.git

# enter the `workbench-docker` folder, create the workbench-lessons named volume, and copy in the R-ecology-lesson content
cd workbench-docker
./scripts/setup_named_volume.sh ~/lessons/R-ecology-lesson
```

You will see output produced:

```bash
lessons/R-ecology-lesson
Creating Docker volume: workbench-lessons
workbench-lessons
Starting temporary container...
62ef5ff3067c75f1e0ba37580d9171147bcf99a8ea64f4e046a56eff5b6b4a33
Copying files to Docker volume...
Successfully copied 942MB to temp_copy_container:/home/rstudio/lessons/R-ecology-lesson
Cleaning up...
Data successfully copied to volume 'workbench-lessons'.
total 4
drwxr-xr-x   11 1000     1000          4096 Feb 21 15:44 R-ecology-lesson
```

Your new `workbench-lessons` named volume now contains the `R-ecology-lesson` lesson!

A key benefit is that the lesson inside the named volume is still a git repository, so you can use git commands within the container to make changes and commit and push them like you would on your host operating system.

#### Adding other lessons to the named volume

The named volume can store any number of lessons you wish to manage.

To add another lesson to the existing `workbench-lessons` named volume, rerun the `setup_named_volume.sh` script:

```bash
./setup_named_volume.sh ~/lessons/shell-novice
```

#### Using the `workbench-lessons` named volume

Within an R session running inside the container:

```bash
docker run --rm -it --name wb --user rstudio -v workbench-lessons:/home/rstudio/lessons carpentries/workbench-docker:latest R
```

Within an RStudio instance running inside the container, specifying a lesson name that is in your named volume as the final argument, e.g. `R-ecology-lesson` or `shell-novice`:

```bash
docker run -it \
--name workbench_rstudio \
--user rstudio \
-p 8787:8787 \
-v workbench-lessons:/home/rstudio/lessons \
-e DISABLE_AUTH=true \
carpentries/workbench-docker:latest \
/home/rstudio/start.sh shell-novice
```

The start.sh script builds and installs any dependencies, including those specified within a `renv` inside the lesson.

### Mounting a lesson to use with a pre-built image

NOTE: Mounting a local lesson directory directly can raise permissions errors, especially on Mac. We recommend using the named volume system above.

If you already have a lessons folder on your local system that you want to use inside the container, you can mount it directly as a volume in the container.

However, we have to use `docker run` again, but with a few more options.

We can use the `-v` flag to mount a local folder on your system into the container.

In this case, we use `/home/your_user/lessons` as the example folder where your Carpentries lessons is stored, supplying the lesson you want to use as the final argument:

```bash
docker run -it \
--name workbench_rstudio \
--user rstudio \
-p 8787:8787 \
-v /home/your_user/lessons:/home/rstudio/lessons \
-e DISABLE_AUTH=true \
-e USERID=$(id -u) \
-e GROUPID=$(id -g) \
carpentries/workbench-docker:latest \
/home/rstudio/start.sh shell-novice
```

You can now open `localhost:8787` in your browser and you will be able to use a full RStudio server instance from within the container.

Note that changes made to the lesson from within this session will **affect your lesson on your host system**.

The options that can be modified are as follows:
* `name`: the name of the eventual workbench docker container
* `p`: the port on which you can access the RStudio server on your host system - **only** change the port number on the left of the colon, e.g. to use `localhost:8888` instead, supply `-p 8888:8787` as the option
* `v`: the local lessons folder to mount - **only** change the path on the left of the colon, e.g. to use `/home/foo/lessons` as the lesson folder, supply `-v /home/foo/lessons:/home/rstudio/lessons` as the option

Please leave all other options unchanged.

If you don't want to use RStudio Server, you can start an R session directly:

```bash
docker run --rm -it --name wb --user rstudio --env-file .env -v /home/your_user/lessons:/home/rstudio/lessons carpentries/workbench-docker:latest R
```

Then build or serve your lesson:

```r
library(sandpaper)
sandpaper::serve("/home/rstudio/lessons/shell-novice")
```

## Building the images yourself

If an existing workbench container is already running, go to the `workbench-docker` folder and run `docker compose down`.

You may also need to delete other containers and images with Docker Desktop or `docker ps`, `docker stop` and `docker rm`.

### Clone this repository

If you haven't already clone this repository into somewhere suitable, e.g. a `workbench` folder in your home directory:

```bash
cd ~
mkdir workbench
cd workbench
git clone git@github.com:carpentries/workbench-docker.git
```

### Create a named volume

We recommend creating a named volume as per the [instructions above](#using-named-volumes).

### Rebuild the base workbench container

To rebuild the base workbench image that you can use for running R or RStudio:

```bash
cd ~/workbench/workbench-docker
docker compose up --build -d workbench
```

### Build lessons locally

Clone a remote git lesson into somewhere suitable, e.g. a `lessons` folder in your home directory:

```bash
cd ~
mkdir lessons
cd lessons
git clone git@github.com:swcarpentry/shell-novice.git
```

Go into the workbench-docker folder, and run the image with the LESSON_NAME env variable specifying the name of the lesson inside the named volume:

```bash
cd ~/workbench/workbench-docker
docker compose down
LESSON_NAME=shell-novice docker compose up workbench-local
```

This will build the container, and install any required packages including any `renv` dependencies for Rmarkdown lessons.

It will also start a RStudio server inside the container that is accessible on your host system by opening a browser and going to:

`localhost:8787`

Your lesson will be available under the `/home/rstudio/lessons/<lesson-name>` folder inside the container, e.g. `/home/rstudio/lessons/shell-novice`

## Rebuilding the image

To rebuild the image:

```bash
cd ~/workbench/workbench-docker
docker compose down
docker compose up --build -d workbench
```

## Removing previous containers

You can use `docker container list --all` to list current containers. Find the name of the container you wish to remove.

Make sure the container is stopped by using `docker stop <container_name>`.

To remove an existing container, use `docker rm <container_name>`.

You can also use the Docker Desktop app to start, stop and delete containers, images and builds.

Please check the relevant [Docker Desktop documentation](https://docs.docker.com/desktop/).

## Adding extra dependencies

If you have any issues with this image, please email us on `infrastructure at carpentries.org` or head to the `#workbench` channel in our [Slack server](https://slack-invite.carpentries.org/).

## Using Git within the container

The simplest route is to use the `scripts/run_workbench.sh` script as this automatically adds the following options.

To use Git commands within the container, add two bind volumes to your docker command:

```bash
-v ~/.ssh:/home/rstudio/.ssh:ro
-v ~/.gitconfig:/home/rstudio/.gitconfig
```

This will mount your SSH key folder as a read only volume, and your global user gitconfig, inside the container.

A full example:

```bash
docker run -it \
--name workbench_rstudio \
--user rstudio \
-p 8787:8787 \
-v workbench-lessons:/home/rstudio/lessons \
-v ~/.ssh:/home/rstudio/.ssh:ro \
-v ~/.gitconfig:/home/rstudio/.gitconfig \
-e DISABLE_AUTH=true \
carpentries/workbench-docker:latest \
/home/rstudio/start.sh shell-novice
```
