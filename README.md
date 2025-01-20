# workbench-docker

A dockerised image of the Workbench dependencies required to build and serve lessons

## How to Use

1. Install docker or Docker Desktop for your operating system
2. Clone this repository onto your system
3. Open a terminal (bash, zsh, powershell, etc)
4. Change directory to the workbench-docker repository, e.g. `cd workbench-docker`
5. Run `docker compose up`

## Rebuilding the image

If the container is already running, run `docker compose down`.

Run `docker compose --build -d` to rebuild the image.

## Adding extra dependencies

TODO
