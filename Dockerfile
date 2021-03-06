FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive

# Basic packages needed to download dependencies and unpack them.
RUN apt-get update && apt-get install -y \
  bzip2 \
  perl \
  tar \
  wget \
  zip \
  xz-utils \
  && rm -rf /var/lib/apt/lists/*

# Install packages necessary for compilation.
RUN apt-get update && apt-get install -y \
  autoconf \
  automake \
  bash \
  build-essential \
  cmake \
  curl \
  frei0r-plugins-dev \
  gawk \
  libfontconfig-dev \
  libfreetype6-dev \
  libopencore-amrnb-dev \
  libopencore-amrwb-dev \
  libsdl2-dev \
  libspeex-dev \
  libssl-dev \
  libtheora-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvo-amrwbenc-dev \
  libvorbis-dev \
  libwebp-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  libxvidcore-dev \
  lsb-release \
  nasm \
  ninja-build \
  pkg-config \
  python3-pip \
  sudo \
  tar \
  texi2html \
  yasm \
  && rm -rf /var/lib/apt/lists/*

# Install rust and cargo-c
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y \
  && /root/.cargo/bin/cargo install cargo-c

# Install meson
RUN pip3 install meson

# Copy the build scripts.
COPY ./ /ffmpeg-static/
RUN chmod -R ug+rwx /ffmpeg-static
WORKDIR /ffmpeg-static

CMD ["/bin/bash"]