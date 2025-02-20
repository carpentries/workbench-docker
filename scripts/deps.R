library(remotes)

remotes::install_version(package = "pegboard", version = Sys.getenv("PEGBOARD_VER"))
remotes::install_version(package = "varnish", version = Sys.getenv("VARNISH_VER"))
remotes::install_version(package = "sandpaper", version = Sys.getenv("SANDPAPER_VER"))
