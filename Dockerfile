FROM python:3.6.5-stretch

RUN apt-get update && apt-get install -y \
    libssl-dev \
&& rm -rf /var/lib/apt/lists/*

# Build freetds with SSL and MS SQL support
# See https://stackoverflow.com/questions/39395548/how-to-configure-pymssql-with-ssl-support-on-ubuntu
WORKDIR /tmp
RUN wget ftp://ftp.freetds.org/pub/freetds/stable/freetds-1.00.109.tar.gz \
    && tar xzf freetds-1.00.109.tar.gz \
    && cd freetds-1.00.109 \
    && ./configure --with-openssl=/usr/include/openssl --enable-msdblib \
    && make \
    && make install

# Create symlink to fix invalid reference
RUN ln -s /usr/local/lib/libsybdb.so.5 /usr/lib/libsybdb.so.5 \
    && ldconfig

# Number of packages requested by tesseract for build
# For more details please see https://github.com/tesseract-ocr/tesseract/wiki/Compiling
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
&& rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
COPY ./requirements.txt /tmp
RUN git clone https://github.com/DanBloomberg/leptonica.git
RUN git clone https://github.com/UB-Mannheim/tesseract.git

WORKDIR leptonica
RUN git checkout 1.74.4 \
    && ./autobuild && ./configure && make && make install \
    && rm -rf *

# There is a bug into tesseract Makefile. The linker flag `-llept` is missing, and we need to put it by force
# For more details please see https://groups.google.com/forum/#!topic/tesseract-ocr/_MIwN6M0c60
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"
WORKDIR /tmp/tesseract
RUN git checkout 3.05.01 \
    && sed -i -e 's/tesseract_LDADD += -lrt/tesseract_LDADD += -lrt -llept/g' api/Makefile.am \
    && ./autogen.sh && ./configure && make && make install \
    && rm -rf * \
    && wget -O /usr/local/share/tessdata/eng.traineddata https://github.com/tesseract-ocr/tessdata/raw/master/eng.traineddata \
    && wget -O /usr/local/share/tessdata/osd.traineddata https://github.com/tesseract-ocr/tessdata/raw/master/osd.traineddata \
    && pip install --no-cache cython==0.29.1

RUN pip install --no-cache -r /tmp/requirements.txt

COPY ./num.traineddata /usr/local/share/tessdata/
