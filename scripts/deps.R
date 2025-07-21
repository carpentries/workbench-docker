library(remotes)
library(httr)

install_latest_release <- function(pkg) {
  api_url <- paste0("https://api.github.com/repos/carpentries/", pkg, "/releases/latest")
  resp <- httr::GET(api_url)

  if (status_code(resp) == 200) {
    tag <- content(resp, as = "parsed", type = "application/json")$tag_name
    message("Installing ", pkg, " from GitHub @", tag)
    renv::install(paste0("carpentries/", pkg, "@", tag))
  } else {
    message("Failed to get GitHub release tag for ", pkg)
    message("Falling back to install.packages()")
    install.packages(pkg)
  }
}

# Set the default HTTP user agent to get pre-built binary packages
RV <- getRversion()
OS <- paste(RV, R.version["platform"], R.version["arch"], R.version["os"])
options(HTTPUserAgent = sprintf("R/%s R (%s)", RV, OS))

cat("::group::Register Repositories\n")
on_linux <- Sys.info()[["sysname"]] == "Linux"
if (on_linux) {
    if (Sys.getenv("RSPM") == "") {
        release <- system("lsb_release -c | awk '{print $2}'", intern = TRUE)
        Sys.setenv("RSPM" =
            paste0("https://packagemanager.posit.co/all/__linux__/", release, "/latest")
        )
    }
}

repos <- list(
    RSPM        = Sys.getenv("RSPM"),
    carpentries = "https://carpentries.r-universe.dev/",
    archive     = "https://carpentries.github.io/drat/",
    CRAN        = "https://cran.rstudio.com"
)

options(pak.no_extra_messages = TRUE, repos = repos)

cat("Repositories Used")
print(getOption("repos"))
cat("::endgroup::\n")

sand_deps <- remotes::package_deps("sandpaper")
varn_deps <- remotes::package_deps("varnish")
sess_deps <- remotes::package_deps("sessioninfo")
with_deps <- remotes::package_deps("withr")
pkgs      <- rbind(sand_deps, varn_deps, sess_deps, with_deps)
print(pkgs)
update(pkgs, upgrade = "always")

install_latest_release("sandpaper")
install_latest_release("varnish")
install_latest_release("pegboard")
