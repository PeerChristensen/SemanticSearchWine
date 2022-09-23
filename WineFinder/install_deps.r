
install.packages(c("tidyverse","shiny","reticulate", "vroom", "shinythemes", "shinyWidgets"),
                 repos = "http://cran.us.r-project.org")

# reticulate::install_miniconda()
# 
# reticulate::conda_create(envname = "docker_wine_rec")
# reticulate::conda_install(envname = "docker_wine_rec",
#                           packages = c("numpy", "pandas", "torch", "sentence-transformers"),
#                           pip = TRUE)
# reticulate::use_condaenv("docker_wine_rec")
# reticulate::use_python('/root/.local/share/r-miniconda/envs/docker_wine_rec/bin/python')
