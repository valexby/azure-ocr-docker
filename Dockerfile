FROM alexvasiuk/python_alpine_cv2_tf

COPY ./requirements.txt ./requirements.txt

RUN rm -rf /usr/bin/pip \
    && ln -s /usr/bin/pip3 /usr/bin/pip \
    && apk add --update --no-cache \
        --allow-untrusted \
        --repository http://dl-3.alpinelinux.org/alpine/edge/testing  \
        --virtual .run-deps \
        tiff \
        'tesseract-ocr=3.05.02-r0' \
        freetds \
        hdf5 \
        libffi \
        openssl \
        freetype \
        leptonica \
        libxml2 \
        libxslt \
    && apk add --update --no-cache --allow-untrusted \
        --repository http://dl-3.alpinelinux.org/alpine/edge/testing  \
        --virtual .build-deps \
        build-base \
        hdf5-dev \
        libffi-dev \
        openssl-dev \
        freetype-dev \
        leptonica-dev \
        'tesseract-ocr-dev=3.05.02-r0' \
        libxml2-dev \
        libxslt-dev \
        freetds-dev \
        python-dev \
    && rm -rf /var/cache/apk/*
RUN pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps
