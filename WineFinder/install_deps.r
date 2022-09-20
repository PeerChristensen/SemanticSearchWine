
install.packages("reticulate", "vroom", "shinythemes", "shinyWidgets")

reticulate::install_miniconda()
?reticulate::conda_create()
reticulate::conda_install(packages = "python=3.9")

RUN R -q -e 'reticulate::conda_create(envname = "r-autogluon", packages = c("python=3.8.13", "numpy"))'
# RUN R -q -e 'reticulate::conda_list()'
RUN R -q -e 'reticulate::conda_install(envname = "r-autogluon", packages = "autogluon", pip = TRUE)'


## Modify Rprofile
RUN R -e 'write("reticulate::use_condaenv(\"r-autogluon\", required = TRUE)",file=file.path(R.home(),"etc","Rprofile.site"),append=TRUE)'
RUN R -e 'write("reticulate::import(\"autogluon.tabular\")",file=file.path(R.home(),"etc","Rprofile.site"),append=TRUE)'
