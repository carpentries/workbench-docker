library(remotes)

sand_deps <- remotes::package_deps("sandpaper")
varn_deps <- remotes::package_deps("varnish")
sess_deps <- remotes::package_deps("sessioninfo")
with_deps <- remotes::package_deps("withr")
pkgs      <- rbind(sand_deps, varn_deps, sess_deps, with_deps)
print(pkgs)
update(pkgs, upgrade = "always")

remotes::install_version(package = "pegboard", version = Sys.getenv("PEGBOARD_VER"))
remotes::install_version(package = "varnish", version = Sys.getenv("VARNISH_VER"))
remotes::install_version(package = "sandpaper", version = Sys.getenv("SANDPAPER_VER"))
