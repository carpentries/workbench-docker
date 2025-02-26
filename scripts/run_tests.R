source("/home/rstudio/.workbench/setup_lesson_deps.R")
source("/home/rstudio/.workbench/fortify_renv_cache.R")

library(sandpaper)
sandpaper::package_cache_trigger(TRUE)
sandpaper::build_lesson(
    path = "/home/rstudio/lesson",
    rebuild = TRUE,
    quiet = FALSE,
    preview = FALSE
)
