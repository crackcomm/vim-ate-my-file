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

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Warsaw
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends sudo less locales tzdata && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales

ARG UNAME=pah
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME
RUN usermod -aG sudo $UNAME
RUN echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
USER ${UNAME}

COPY . /home/${UNAME}/dot-repo
WORKDIR /home/${UNAME}/dot-repo

ENV HOME="/home/${UNAME}"
ENV PATH="$PATH:$HOME/.local/nvim-linux64/bin"
RUN sudo -E bash -c "./install/install.sh && chown -hR $UNAME $HOME"
RUN /bin/zsh -c 'nvim -es -u $HOME/.config/nvim/init.vim -i NONE -c "PlugInstall --sync" -c "qa" || true'
ENV DEBIAN_FRONTEND=

RUN cp /home/${UNAME}/dot-repo/.jjconfig.toml /home/${UNAME}/.jjconfig.toml

WORKDIR /home/${UNAME}
ENTRYPOINT /bin/zsh
