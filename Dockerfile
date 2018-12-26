FROM alexvasiuk/python_alpine_cv2_tf

COPY ./requirements.txt ./requirements.txt

RUN apk add --update --no-cache \
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
        hdf5-dev \
        libffi-dev \
        openssl-dev \
        freetype-dev \
        leptonica-dev \
        'tesseract-ocr-dev=3.05.02-r0' \
        libxml2-dev \
        libxslt-dev \
        freetds-dev \
    && rm -rf /var/cache/apk/* \
    && pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps
