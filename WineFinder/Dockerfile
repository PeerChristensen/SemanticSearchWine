FROM rocker/shiny-verse:4.0.0

# Install system requirements for index.R as needed
RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev

#COPY ./www/* /srv/shiny-server/www/
ADD install_deps.r /tmp/install_deps.r
RUN Rscript /tmp/install_deps.r

ADD environment.yml /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml

#COPY Rprofile.site /etc/R
#RUN install2.r --error --skipinstalled \
#    shiny 

#COPY ./app/* /srv/shiny-server/
#COPY . ./app

# Give write read/write permission
RUN chmod ugo+rwx /app

#USER shiny

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]
