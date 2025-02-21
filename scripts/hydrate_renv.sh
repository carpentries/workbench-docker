#!/bin/bash

# if [ -f .renv/profiles/lesson-requirements/renv.lock ]; then
#   echo "Found renv lockfile, restoring...";
#   R -e 'renv::restore(lockfile = ".renv/profiles/lesson-requirements/renv.lock", library = ".renv/profiles/lesson-requirements/renv/library", prompt = FALSE)';
#   R -e 'library(sandpaper)';
#   R -e 'sandpaper::manage_deps(path = ".renv")';
# fi

Rscript /home/rstudio/setup_lesson_deps.R
