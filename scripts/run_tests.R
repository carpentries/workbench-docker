setwd("/home/rstudio/lesson")

source("/home/rstudio/.workbench/setup_lesson_deps.R")
source("/home/rstudio/.workbench/fortify_renv_cache.R")

library(sandpaper)
sandpaper::package_cache_trigger(TRUE)
# sandpaper:::ci_deploy(reset = TRUE,
#   md_branch = "markdown",
#   site_branch = "site"
# )
sandpaper::build_lesson()
