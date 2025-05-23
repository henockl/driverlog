FROM arm64v8/debian:bookworm-slim as builder


ENV POSTGIS_VERSION=3.5.3
ENV GEOS_VERSION=3.13.1
ENV GDAL_VERSION=3.11.0
ENV CC=gcc
ENV CXX=g++

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    autoconf \
    automake \
    cmake \
    make \
    perl \
    python3-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libsqlite3-dev \
    libtiff-dev \
    libjpeg-dev \
    zlib1g-dev \
    libpng-dev \
    libexpat-dev \
    libxml2-dev \
    libpq-dev \
    libproj-dev \
    libprotobuf-c-dev \
    protobuf-c-compiler \
    pkg-config \
    ca-certificates

RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/pgdg.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get install -y postgresql-server-dev-17

# Build GEOS from source
RUN curl -LO https://download.osgeo.org/geos/geos-3.13.1.tar.bz2 && \
    tar -xjf geos-3.13.1.tar.bz2 && \
    cd geos-3.13.1 && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    cd .. && rm -rf geos-3.13.1*

# Build GDAL from source
RUN curl -L https://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz | tar xz && \
    cd gdal-${GDAL_VERSION} && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    cd ../.. && rm -rf gdal-${GDAL_VERSION}

# Build PostGIS from source
RUN curl -L https://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz \
  | tar xz && \
  cd postgis-${POSTGIS_VERSION} && \
  ./configure && \
  make -j$(nproc) && \
  make install && \
  cd .. && rm -rf postgis-${POSTGIS_VERSION}

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-postgis.sh /usr/local/bin


FROM arm64v8/postgres:17.5-bookworm

COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/share /usr/share
COPY --from=builder /usr/lib /usr/lib

ENV LD_LIBRARY_PATH=/usr/local/lib

COPY create_db.sh /docker-entrypoint-initdb.d/create_db.sh
