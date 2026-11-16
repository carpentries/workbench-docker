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
        "hunspell",
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
