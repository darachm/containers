FROM ubuntu:20.04 AS r-base

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ARG DEBIAN_FRONTEND="noninteractive"

RUN ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
RUN apt-get update && apt-get install -y \
    apt-transport-https software-properties-common dirmngr wget
RUN wget -qO- \
        https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
    | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
RUN apt-get update && apt-get -y install --no-install-recommends r-base r-base-dev 

FROM r-base AS r

RUN apt-get update && apt-get -y install --no-install-recommends \
    vim gnupg2 git wget g++ gcc libxml2-dev libssl-dev \
    curl libcurl4-openssl-dev pandoc \
    libfontconfig1-dev libgit2-dev \
    tmux rxvt-unicode
RUN apt upgrade -y

FROM r AS r-tidy

RUN Rscript -e 'install.packages("tidyverse",dependencies=T);'
RUN Rscript -e 'install.packages("magrittr",dependencies=T);'
RUN Rscript -e 'install.packages("devtools",dependencies=T);'

FROM r-tidy AS r-tidy-db

RUN Rscript -e 'install.packages("hash",dependencies=T);'
RUN Rscript -e 'install.packages("stringdist",dependencies=T);'
RUN Rscript -e 'install.packages("DBI",dependencies=T);'
RUN Rscript -e 'install.packages("RSQLite",dependencies=T);'
RUN Rscript -e 'install.packages("jsonlite",dependencies=T);'
RUN Rscript -e 'install.packages("fst",dependencies=T);'

FROM r-tidy-db AS r-tidy-db-viz

RUN Rscript -e 'install.packages("ggally",dependencies=T);'
RUN Rscript -e 'install.packages("egg",dependencies=T);'
RUN Rscript -e 'install.packages("cowplot",dependencies=T);'
RUN Rscript -e 'install.packages("ggrepel",dependencies=T);'
RUN Rscript -e 'install.packages("pheatmap",dependencies=T);'
RUN Rscript -e 'install.packages("ggalluvial",dependencies=T);'
RUN Rscript -e 'install.packages("pracma",dependencies=T);'
RUN Rscript -e 'install.packages("vegan",dependencies=T);'
RUN Rscript -e 'install.packages("UPSetR",dependencies=T);'
RUN Rscript -e 'install.packages("ghibli",dependencies=T);'
RUN Rscript -e 'install.packages("hexbin",dependencies=T);'
RUN Rscript -e 'install.packages("ggsignif",dependencies=T);'
RUN Rscript -e 'devtools::install_github("LKremer/ggpointdensity",dependencies=T);'

RUN Rscript -e 'install.packages("EBImage",dependencies=T);'

FROM r-tidy-db-viz AS r-tidy-db-viz-mod

RUN Rscript -e 'install.packages("mcr",dependencies=T);'
RUN Rscript -e 'install.packages("limma",dependencies=T);'
RUN Rscript -e 'install.packages("vegan",dependencies=T);'
RUN Rscript -e 'install.packages("randomForest",dependencies=T);'
RUN Rscript -e 'install.packages("xgboost",dependencies=T);'


FROM r-tidy-db-viz-mod AS r-tidy-db-viz-mod-bio

RUN Rscript -e 'install.packages("BiocManager",dependencies=T);'
RUN Rscript -e 'BiocManager::install(version="3.14",ask=F)'
RUN Rscript -e 'BiocManager::install(version="3.14","org.Sc.sgd.db",ask=F);'
RUN Rscript -e 'BiocManager::install(version="3.14","Biobase",ask=F);'
RUN Rscript -e 'BiocManager::install(version="3.14","ggbio",ask=F)'
RUN Rscript -e 'BiocManager::install(version="3.14","GOSemSim",ask=F);'
RUN Rscript -e 'BiocManager::install(version="3.14","clusterProfiler",ask=F);'
RUN Rscript -e 'BiocManager::install(version="3.14","variancePartition",ask=F);'
RUN Rscript -e 'BiocManager::install(version="3.14","DESeq2",ask=F);'

