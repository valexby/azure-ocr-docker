FROM alexvasiuk/python_alpine_cv2_tf

COPY ./requirements.txt ./requirements.txt

RUN apk add --update --no-cache --virtual .run-deps \
        tiff \
        'tesseract-ocr=3.05.02-r0' \
        freetds-dev \
    && apk add --update --no-cache --virtual .build-deps \
        libffi-dev \
        openssl-dev \
        freetype-dev \
        leptonica-dev \
        'tesseract-ocr-dev=3.05.02-r0' \
        libxml2-dev \
        libxslt-dev \
    && apk add --update --no-cache hdf5-dev@testing \
    && rm -rf /var/cache/apk/* \
    && pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps
