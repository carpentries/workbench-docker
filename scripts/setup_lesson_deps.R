cat("::group::Register Repositories\n")
on_linux <- Sys.info()[["sysname"]] == "Linux"

is_root_euid <- function() {
  result <- system("id -u", intern = TRUE)
  return(as.numeric(result) == 0)
}

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
    ropensci    = "https://ropensci.r-universe.dev/",
    archive     = "https://carpentries.github.io/drat/",
    CRAN        = "https://cran.rstudio.com"
)

options(pak.no_extra_messages = TRUE, repos = repos)

cat("Repositories Used")
print(getOption("repos"))
cat("::endgroup::\n")

# Set up system dependencies
req <- function(pkg, ...) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        install.packages(pkg, ...)
    }
}

wd <- "."
has_lock <- file.exists(file.path(wd, 'renv'))
if (on_linux && has_lock) {
    req("renv")
    req("remotes")
    rmts <- asNamespace("remotes")
    # extract the function
    sov <- rmts$supported_os_versions
    # if 24.04 is not present, we need to modify the function
    if (!grepl("24.04", body(sov)[2])) {
        unlockBinding("supported_os_versions", rmts)
        # modify the list in the body to include 22.04
        vers <- eval(parse(text = as.character(body(sov)[2])))
        vers$ubuntu <- c(vers$ubuntu, "24.04")
        # replace the body
        body(sov)[2] <- list(str2lang(paste(capture.output(dput(vers)), collapse = "")))
        # replace the function in the namespace
        rmts$supported_os_versions <- sov
    }
    req("desc")
    remotes::install_github("carpentries/vise@frog-pak-bork-1")
    if (file.exists("DESCRIPTION")) {
        file.rename("DESCRIPTION", "DESCRIPTION.bak")
    }
    Sys.setenv("RENV_PROFILE" = "lesson-requirements")
    Sys.setenv("RSPM_ROOT" = "https://packagemanager.posit.co")
    vise::lock2desc(renv::paths$lockfile(), desc = "DESCRIPTION")
    writeLines(readLines("DESCRIPTION"))

    # hack to get around sudo being hardcoded into vise apt-get update
    sudo <- FALSE
    if (on_linux) {
        if (is_root_euid()) {
            system("apt-get update")
        }
        else {
            system("sudo apt-get update")
            sudo <- TRUE
        }
    }

    vise::ci_sysreqs(renv::paths$lockfile(), execute = TRUE, sudo = sudo)
}
