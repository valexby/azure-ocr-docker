FROM python:3.6.8-stretch

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

WORKDIR /tmp

RUN apt-get update && apt-get install -y \
        g++ \
        autoconf \
        automake \
        libtool \
        autoconf-archive \
        pkg-config \
        libpng-dev \
        libjpeg-dev \
        libtiff5-dev \
        zlib1g-dev \
        libicu-dev \
        libpango1.0-dev \
        libcairo2-dev \
        imagemagick \
        ghostscript \
        apt-transport-https \
        libssl-dev \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 \
    && apt-get install -y unixodbc-dev \
    && ln -s /usr/local/lib/libsybdb.so.5 /usr/lib/libsybdb.so.5 \
    && ldconfig \
    && rm -rf /var/lib/apt/lists/* \
    && cd /tmp \
    && git config --global http.postBuffer 524288000 \
    && git clone https://github.com/DanBloomberg/leptonica.git \
    && git clone https://github.com/UB-Mannheim/tesseract.git \
    && cd /tmp/leptonica \
    && git checkout 1.74.4 \
    && ./autobuild && ./configure && make && make install \
    && rm -rf * \
    && cd /tmp/tesseract \
    && git checkout 3.05.01 \
    && sed -i -e 's/tesseract_LDADD += -lrt/tesseract_LDADD += -lrt -llept/g' api/Makefile.am \
    && ./autogen.sh && ./configure && make && make install \
    && rm -rf * \
    && wget -O /usr/local/share/tessdata/eng.traineddata https://github.com/tesseract-ocr/tessdata/raw/master/eng.traineddata \
    && wget -O /usr/local/share/tessdata/osd.traineddata https://github.com/tesseract-ocr/tessdata/raw/master/osd.traineddata \
    && pip install --no-cache cython==0.29.1

COPY ./num.traineddata /usr/local/share/tessdata/
COPY ./requirements.txt /tmp/

RUN pip install --no-cache -r /tmp/requirements.txt
