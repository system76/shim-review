FROM ubuntu:jammy

RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list && \
    apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl && \
    DEBIAN_FRONTEND=noninteractive apt-get build-dep -y shim

COPY . /shim-review

RUN curl --location --remote-name https://github.com/rhboot/shim/releases/download/15.7/shim-15.7.tar.bz2 && \
    sha256sum --check /shim-review/SHA256SUMS && \
    tar xvf shim-15.7.tar.bz2 && \
    mv shim-15.7 shim
    
WORKDIR /shim
RUN cp /shim-review/sbat.csv data/sbat.csv && \
    make ARCH=x86_64 VENDOR_CERT_FILE=/shim-review/db.cer
WORKDIR /

# FIXME: This only works on x86-64 efi binary
RUN hexdump -Cv /shim-review/shimx64.efi > orig && \
    hexdump -Cv /shim/shimx64.efi > build && \
    diff -u orig build
