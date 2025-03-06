#!/bin/bash

echo "Setting up the workbench for $LESSON_NAME ..."

if [ "$WORKBENCH_PROFILE" == "local" ]; then
    echo "Running local renv restore ..."

    # Restore renv before running
    cd "/home/rstudio/lessons/$LESSON_NAME"

    Rscript /home/rstudio/.workbench/setup_lesson_deps.R
    Rscript /home/rstudio/.workbench/fortify_renv_cache.R
fi

# Start the usual container workflow
 /init
