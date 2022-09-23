FROM continuumio/miniconda3 AS base

RUN apt-get update -y; apt-get upgrade -y; \
    apt-get install -y vim-tiny vim-athena ssh r-base-core \
    build-essential gcc gfortran g++ 

# SETUP ENVIRONMENT
COPY environment.yml environment.yml
RUN conda env create -f environment.yml

RUN echo "source activate wine_rec" >> ~/.bashrc

ENV CONDA_EXE /opt/conda/bin/conda
ENV CONDA_PREFIX /opt/conda/envs/wine_rec
ENV CONDA_PYTHON_EXE /opt/conda/bin/python
ENV CONDA_PROMPT_MODIFIER (wine_rec)
ENV CONDA_DEFAULT_ENV wine_rec
ENV PATH /opt/conda/envs/wine_rec/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# GET MODEL
ADD https://public.ukp.informatik.tu-darmstadt.de/reimers/sentence-transformers/v0.2/msmarco-MiniLM-L-6-v3.zip .
RUN unzip ./msmarco-MiniLM-L-6-v3.zip -d /model && rm ./msmarco-MiniLM-L-6-v3.zip

# INSTALL R PACKAGES
#COPY install_deps.r /tmp/install_deps.r
#RUN Rscript /tmp/install_deps.r
RUN R -e "install.packages(c('shiny','dplyr','reticulate','vroom', 'shinythemes','shinyWidgets'), repos = 'http://cran.us.r-project.org')"

FROM base

COPY . ./

# Give write read/write permission
RUN chmod ugo+rwx ./

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/', host = '0.0.0.0', port = 3838)"]
