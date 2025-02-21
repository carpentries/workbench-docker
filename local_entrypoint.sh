#!/bin/bash

if [ "$WORKBENCH_PROFILE" == "local" ]; then
    echo "Running local renv restore ..."

    # Restore renv before running
    cd /home/rstudio/lesson

    Rscript /home/rstudio/.workbench/setup_lesson_deps.R
    Rscript /home/rstudio/.workbench/fortify_renv_cache.R
fi

# Start the usual container workflow
 /init
