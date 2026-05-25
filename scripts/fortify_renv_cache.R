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
            } else {
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

Sys.unsetenv("RENV_CONFIG_REPOS_OVERRIDE")
options(pak.no_extra_messages = TRUE, repos = repos)

cat("Repositories Used")
print(getOption("repos"))
cat("::endgroup::\n")

Sys.setenv("RENV_PROFILE" = "lesson-requirements")

wd <- "."
req <- function(pkg) {
    if (!requireNamespace(pkg, quietly = TRUE))
        install.packages(pkg)
}

site_libs <- strsplit(Sys.getenv("R_LIBS_SITE"), ":")[[1]]
site_libs <- site_libs[site_libs != ""]

if (!is.null(site_libs) && length(site_libs) > 0) {
    cli::cli_alert("Bootstrapping site libraries")
    options(renv.settings.external.libraries = site_libs)
    .libPaths(c(site_libs, .libPaths()))
}

if (file.exists("DESCRIPTION")) {
    req("remotes")
    remotes::install_deps()
}
cat("::endgroup::\n")

if (file.exists(file.path(wd, 'renv'))) {
    cat("::group::Fortify local {renv} packages\n")
    if (file.exists("DESCRIPTION.bak")) {
        file.rename("DESCRIPTION.bak", "DESCRIPTION")
    } else {
        try(file.remove("DESCRIPTION"), silent = TRUE)
    }
    req("renv")

    cat("Loading {renv} project\n")
    renv::load(path = wd, profile = "lesson-requirements")

    cat("Installing lesson dependencies with {sandpaper}\n")
    tryCatch(sandpaper::manage_deps(path = wd, profile = "lesson-requirements", quiet = FALSE, use_site_libs = TRUE),
        error = function(e) {
            iss <- "https://github.com/rstudio/renv/issues/1184"
            cli::cli_alert_danger("run failed... attempting to re-run (see {.url {iss}} for details.")
            sandpaper::manage_deps(path = wd, profile = "lesson-requirements", quiet = FALSE, use_site_libs = TRUE)
        }
    )
    cat("::endgroup::\n")
} else {
    writeLines("Package cache not used")
}
