# Stage 1 - Build the toolchain
FROM arm32v7/debian:bullseye

ARG MIPSEL=/mipsel-none-elf
ENV MIPSEL=${MIPSEL}

# install dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=US/Central \
    apt-get install -yq --no-install-recommends wget bzip2 \
    build-essential apt-utils autoconf automake zlib1g-dev \
    bison flex texinfo file ca-certificates elfutils \
    libdebuginfod-dev

RUN apt-get clean

# Build
COPY ./build.sh /tmp/build.sh
WORKDIR /tmp
RUN ./build.sh

# Stage 2 - Prepare minimal image
FROM arm32v7/debian:bullseye
ARG MIPSEL=/mipsel-none-elf
ENV MIPSEL=${MIPSEL}
ENV PATH="${MIPSEL}/bin:$PATH"

COPY --from=0 ${MIPSEL} ${MIPSEL}
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    gcc g++ make && \
    apt-get clean && \
    apt autoremove -yq
