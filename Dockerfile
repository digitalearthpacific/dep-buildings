FROM ghcr.io/osgeo/gdal:ubuntu-full-3.8.4

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libsqlite3-dev \
    zlib1g-dev \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/{apt,dpkg,cache,log}

RUN git clone https://github.com/mapbox/tippecanoe /tmp/tippecanoe
WORKDIR /tmp/tippecanoe

RUN make \
  && make install
