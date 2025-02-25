source(setup_lesson_deps.R)
source(fortify_renv_cache.R)

library(sandpaper)
sandpaper::package_cache_trigger(TRUE)
sandpaper:::ci_deploy(reset = TRUE,
  md_branch = "markdown",
  site_branch = "site"
)
