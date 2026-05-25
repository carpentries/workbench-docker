wd <- "."
has_lock <- file.exists(file.path(wd, 'renv'))

if (has_lock) {
    cat("::group::Register Repositories\n")
    on_linux <- Sys.info()[["sysname"]] == "Linux"

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

    is_root_euid <- function() {
        result <- system("id -u", intern = TRUE)
        return(as.numeric(result) == 0)
    }

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

    if (on_linux) {
        req("renv")
        req("remotes")
        rmts <- asNamespace("remotes")
        # extract the function
        sov <- rmts$supported_os_versions
        # if 24.04 is not present, we need to modify the function
        if (release$distro == "ubuntu") {
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
        }
        req("desc")
        remotes::install_github("carpentries/vise@main")
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
            if (release$distro == "ubuntu") {
                if (is_root_euid()) {
                    system("apt-get update")
                }
                else {
                    system("sudo apt-get update")
                    sudo <- TRUE
                }
            } else if (release$distro == "alpine") {
                system("apk update")
            }
        }

        vise::ci_sysreqs(renv::paths$lockfile(), execute = TRUE, sudo = sudo)
    }
}