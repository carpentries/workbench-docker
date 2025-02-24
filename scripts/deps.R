library(remotes)

# Set the default HTTP user agent to get pre-built binary packages
RV <- getRversion()
OS <- paste(RV, R.version["platform"], R.version["arch"], R.version["os"])
codename <- sub("Codename.\t", "", system2("lsb_release", "-c", stdout = TRUE))
options(HTTPUserAgent = sprintf("R/%s R (%s)", RV, OS))

# register the repositories for The Carpentries and CRAN
options(repos = c(
  carpentries = "https://carpentries.r-universe.dev/",
  CRAN = paste0("https://packagemanager.posit.co/all/__linux__/", codename, "/latest")
))

# Install the template packages to your R library
# install.packages(c("sandpaper", "varnish", "pegboard"))

sand_deps <- remotes::package_deps("sandpaper")
varn_deps <- remotes::package_deps("varnish")
sess_deps <- remotes::package_deps("sessioninfo")
with_deps <- remotes::package_deps("withr")
pkgs      <- rbind(sand_deps, varn_deps, sess_deps, with_deps)
print(pkgs)
update(pkgs, upgrade = "always")

# Install the template packages to your R library
install.packages(c("sandpaper", "varnish", "pegboard"))
