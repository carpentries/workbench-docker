library(remotes)
library(httr)

detect_linux_distro <- function() {
    if (Sys.info()[["sysname"]] == "Linux") {
        os_release <- readLines("/etc/os-release")
        distro <- sub("ID=(.*)$", "\\1", os_release[grepl("^ID=", os_release)])
        release <- sub("VERSION_ID=(.*)$", "\\1", os_release[grepl("^VERSION_ID=", os_release)])
        codename <- ""
        if (distro == "ubuntu") {
            codename <- sub("UBUNTU_CODENAME=(.*)$", "\\1", os_release[grepl("^UBUNTU_CODENAME=", os_release)])
        }
        return(list(distro = distro, version = release, codename = codename))
    }
    return(NULL)
}

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
    release <- detect_linux_distro()
    if (Sys.getenv("RSPM") == "") {
        if (!is.null(release)) {
            distro <- release$distro
            version <- release$version
            if (distro == "ubuntu") {
                codename <- release$codename
                Sys.setenv("RSPM" =
                    paste0("https://packagemanager.posit.co/all/__linux__/", codename, "/latest")
                )
            } else if (distro == "alpine") {
                Sys.setenv("RSPM" =
                    paste0("https://packagemanager.posit.co/cran/latest")
                )
            }
        }
    }
}

repos <- list(
    RSPM        = Sys.getenv("RSPM"),
    carpentries = "https://carpentries.r-universe.dev/",
    archive     = "https://carpentries.github.io/drat/",
    CRAN        = "https://cran.rstudio.com"
)

options(pak.no_extra_messages = TRUE, repos = repos)

cat("Repositories Used\n")
print(getOption("repos"))
cat("::endgroup::\n")

# install common dependencies for lessons that use Rmarkdown
minimal_deps <- Sys.getenv("MINIMAL", "FALSE")
if (isFALSE(as.logical(minimal_deps))) {
    cat("::group::Installing full common dependencies\n")
    common_deps <- c(
        "base64enc",
        "bit",
        "bit64",
        "bslib",
        "cachem",
        "cli",
        "cpp11",
        "crayon",
        "curl",
        "devtools",
        "digest",
        "dplyr",
        "evaluate",
        "fastmap",
        "fontawesome",
        "fs",
        "ggplot2",
        "glue",
        "highr",
        "htmltools",
        "htmlwidgets",
        "inline",
        "jquerylib",
        "jsonlite",
        "knitr",
        "lifecycle",
        "lubridate",
        "Matrix",
        "magrittr",
        "memoise",
        "mime",
        "pillar",
        "pkgconfig",
        "purrr",
        "R6",
        "Rcpp",
        "RcppArmadillo",
        "RcppParallel",
        "ragg",
        "rappdirs",
        "raster",
        "readr",
        "reprex",
        "rlang",
        "rmarkdown",
        "sass",
        "selectr",
        "stringi",
        "stringr",
        "svglite",
        "sys",
        "systemfonts",
        "textshaping",
        "tibble",
        "tidyr",
        "tidyverse",
        "tinytex",
        "tzdb",
        "uuid",
        "vctrs",
        "vroom",
        "whisker",
        "withr",
        "xfun",
        "xml2"
    )
    cat("::endgroup::\n")
} else {
    cat("::group::Installing minimal common dependencies\n")
    common_deps <- c(
        "curl",
        "devtools",
        "evaluate",
        "fs",
        "glue",
        "htmltools",
        "jsonlite",
        "knitr",
        "purrr",
        "rmarkdown",
        "sys",
        "tinytex",
        "withr",
        "whisker",
        "xfun"
    )
    cat("::endgroup::\n")
}

# Install common deps
for (pkg in common_deps) {
    install.packages(pkg)
}

cat("::group::Install Workbench package dependencies\n")
sand_deps <- remotes::package_deps("sandpaper")
varn_deps <- remotes::package_deps("varnish")
sess_deps <- remotes::package_deps("sessioninfo")
with_deps <- remotes::package_deps("withr")
pkgs      <- rbind(sand_deps, varn_deps, sess_deps, with_deps)
print(pkgs)
update(pkgs, upgrade = "always")
cat("::endgroup::\n")

cat("::group::Install Workbench packages\n")
sandpaper_ref <- Sys.getenv("SANDPAPER_REF", "main")
varnish_ref <- Sys.getenv("VARNISH_REF", "main")
pegboard_ref <- Sys.getenv("PEGBOARD_REF", "main")
use_latest <- isFALSE(as.logical(Sys.getenv("NO_LATEST", "FALSE")))

message("Use latest workbench packages? [", use_latest, "]")
if (use_latest) {
    install_latest_release("sandpaper")
    install_latest_release("varnish")
    install_latest_release("pegboard")
} else {
    message("Installing sandpaper (", sandpaper_ref, "), varnish (", varnish_ref, "), and pegboard (", pegboard_ref, ")")
    remotes::install_github("carpentries/sandpaper", ref = sandpaper_ref)
    remotes::install_github("carpentries/varnish", ref = varnish_ref)
    remotes::install_github("carpentries/pegboard", ref = pegboard_ref)
}
cat("::endgroup::\n")

cat("::group::Install dovetail translation package\n")
remotes::install_github("joelnitta/dovetail")
cat("::endgroup::\n")

