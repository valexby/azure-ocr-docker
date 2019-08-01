FROM python:3.6.8-slim-stretch as builder

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib" \
    DEBIAN_FRONTEND=noninteractive \
    ACCEPT_EULA=Y

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
        git

ADD https://packages.microsoft.com/config/debian/9/prod.list /etc/apt/sources.list.d/mssql-release.list
ADD https://github.com/tesseract-ocr/tessdata/raw/master/eng.traineddata /usr/local/share/tessdata/eng.traineddata
ADD https://github.com/tesseract-ocr/tessdata/raw/master/osd.traineddata /usr/local/share/tessdata/osd.traineddata
ADD https://packages.microsoft.com/keys/microsoft.asc ./

RUN apt-key add microsoft.asc && \
        apt-get update && \
        apt-get install -y msodbcsql17 \
        unixodbc-dev && \
        rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/local/lib/libsybdb.so.5 /usr/lib/libsybdb.so.5 && \
        ldconfig

WORKDIR /tmp/leptonica

RUN git clone https://github.com/DanBloomberg/leptonica.git --branch 1.74.4 . && \
        ./autobuild && \
        ./configure && \
        make && \
        make install

WORKDIR /tmp/tesseract

RUN git clone https://github.com/UB-Mannheim/tesseract.git --branch 3.05.01 . && \
        sed -i -e 's/tesseract_LDADD += -lrt/tesseract_LDADD += -lrt -llept/g' api/Makefile.am && \
        ./autogen.sh && \
        ./configure && \
        make && \
        make install

RUN pip install --no-cache cython==0.29.1

COPY ./requirements.txt /tmp/
RUN pip install --no-cache -r /tmp/requirements.txt

FROM python:3.6.8-slim-stretch

COPY --from=builder  /usr/local/ /usr/local/
COPY --from=builder  /usr/bin/ /usr/bin/
COPY --from=builder  /usr/lib/ /usr/lib/
COPY --from=builder  /usr/include/ /usr/include/
COPY --from=builder  /usr/share/ /usr/share/
COPY ./num.traineddata /usr/local/share/tessdata/