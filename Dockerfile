FROM ubuntu:latest

# REQUIRED FOR R SILENT INSTALLATION
ENV DEBIAN_FRONTEND=noninteractive

# Updating Ubuntu packages
RUN apt-get update && yes| apt-get upgrade

RUN apt-get install -y --no-install-recommends \
    libbio-eutilities-perl \
    git \
    wget \
    bash \
    sudo \
    vim \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    openssl \
    curl \
    r-base \
    r-base-dev \
    r-recommended \
    r-cran-httr \
    r-cran-littler \
    littler \
    r-cran-stringr \
    r-cran-dplyr \
    r-cran-bold \
    r-cran-taxize \
    cpanminus \
    parallel \
    vsearch \
    ncbi-blast+ \
    rsync \
    && ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
    && ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
    && install.r docopt
  
# INSTALLING R PACKAGES
RUN install2.r --error \
      --deps TRUE \
      bold \
      rvest \
      stringi \
      qdapDictionaries \
      splitstackshape \
      taxizedb \
      readr \
      optparse

# INSTALL MINICONDA
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh --no-check-certificate \
  && sh Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda \
  && rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH=/opt/miniconda/bin:${PATH}

RUN conda config --add channels defaults \
  && conda config --add channels bioconda \
  && conda config --add channels conda-forge

# INSTALLING PYTHON PACKAGES
RUN conda install -c bioconda \
    biopython \    
    seqkit \
    seqtk -y 

# INSTALLING PERL PACKAGES
RUN cpanm Encode \
 && cpanm LWP::Simple \
 && cpanm LWP::UserAgent \
 && cpanm HTTP::Date \
 && cpanm Bio::LITE::Taxonomy::NCBI \
 && cpanm Bio::DB::EUtilities

WORKDIR /usr/local/src/

# INSTALL KRAKEN2
ENV KRAKEN2_DIR='/opt/kraken2'

RUN git clone https://github.com/DerrickWood/kraken2
RUN cd kraken2 \  
  && sh install_kraken2.sh ${KRAKEN2_DIR}

ENV PATH=${KRAKEN2_DIR}:$PATH

RUN git clone https://github.com/edgarvaldez/MARES_database_pipeline MARES

RUN wget ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdmp.zip
RUN unzip taxdmp.zip -d taxdump
RUN mv taxdump MARES


CMD ["echo", "finish"]
