FROM ubuntu:22.04 AS glibc

ENV DEBIAN_FRONTEND=noninteractive

# https://sourceware.org/bugzilla/attachment.cgi?id=13419&action=diff
COPY containers/patch-v5-1-9.patch .

RUN apt-get update && \
    apt-get install -y patch wget build-essential python3 gawk bison && \
    wget -q https://ftp.gnu.org/gnu/glibc/glibc-2.35.tar.gz && \
    tar -xzf glibc-2.35.tar.gz && \
    cd glibc-2.35 && \
    patch -p1 < ../patch-v5-1-9.patch && \
    mkdir build && cd build && \
    ../configure \
      --prefix=/opt/glibc-2.35 \
      --exec-prefix=/opt/glibc-2.35-exec \
      --disable-profile \
      --disable-debug \
      --disable-sanity-checks \
      --disable-werror \
      --disable-obsolete-rpc \
      --disable-crypt \
      --disable-selinux \
      --disable-isc-symbols \
      --disable-tls \
      --disable-nscd \
      --disable-resolv-res \
      --disable-mathvec \
      CFLAGS="-w -O2" && \
    make -s -j$(nproc) && make install && \
    mv /opt/glibc-2.35-exec/lib/libpthread.a /usr/lib/x86_64-linux-gnu/libpthread.a && \
    mv /opt/glibc-2.35-exec/lib/libpthread.so.0 /usr/lib/x86_64-linux-gnu/libpthread.so.0 && \
    cd / && rm -rf glibc-2.35* && rm -rf /opt/glibc-2.35 /opt/glibc-2.35-exec && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

FROM ubuntu:22.04

COPY --from=glibc /usr/lib/x86_64-linux-gnu/libpthread.a /usr/lib/x86_64-linux-gnu/libpthread.a
COPY --from=glibc /usr/lib/x86_64-linux-gnu/libpthread.so.0 /usr/lib/x86_64-linux-gnu/libpthread.so.0

COPY . /root/dot-repo
WORKDIR /root/dot-repo
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Warsaw
ENV PATH="$PATH:/root/.local/nvim-linux64/bin"
RUN bash install/install.sh
ENV DEBIAN_FRONTEND=
RUN bash -c 'nvim -es -u $HOME/.config/nvim/init.vim -i NONE -c "PlugInstall --sync" -c "qa" || true'
WORKDIR /root
ENTRYPOINT /bin/zsh
