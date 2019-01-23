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
        libssl-dev \
    && wget ftp://ftp.freetds.org/pub/freetds/stable/freetds-1.00.109.tar.gz \
    && tar xzf freetds-1.00.109.tar.gz \
    && cd freetds-1.00.109 \
    && ./configure --with-openssl=/usr/include/openssl --enable-msdblib \
    && make \
    && make install \
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
