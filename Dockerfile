FROM ubuntu:xenial

# Basic packages needed to download dependencies and unpack them.
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y autoconf automake build-essential libass-dev libfreetype6-dev libtheora-dev libtool libvorbis-dev pkg-config texinfo zlib1g-dev libfdk-aac-dev libmp3lame-dev yasm frei0r-plugins-dev libgnutls-dev ladspa-sdk libbluray-dev libxml2-dev libiec61883-dev libavc1394-dev libbs2b-dev libcaca-dev libdc1394-22-dev flite1-dev libgme-dev libgsm1-dev libmodplug-dev libopencv-dev libopenjp2-7-dev libopus-dev libpulse-dev libshine-dev libsnappy-dev libsoxr-dev libssh-dev libspeex-dev libtwolame-dev libvpx-dev libwavpack-dev libwebp-dev libx264-dev libx265-dev libnuma-dev libxvidcore-dev libczmq-dev libzmq5-dev libsodium-dev libpgm-dev libnorm-dev libzvbi-dev libopenal-dev nvidia-opencl-dev libcdio-dev libcdio-cdda-dev libcdio-paranoia-dev librtmp-dev wget

RUN mkdir ~/ffmpeg_sources && cd ~/ffmpeg_sources \
    && wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 \
    && tar xjvf ffmpeg-snapshot.tar.bz2 && cd ffmpeg \
    && PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" --pkg-config-flags="--static" --extra-cflags="-I$HOME/ffmpeg_build/include -static" --extra-ldflags="-L$HOME/ffmpeg_build/lib -static" --bindir="$HOME/bin" \
    --enable-nonfree --toolchain=hardened --enable-gpl --disable-shared --disable-stripping --enable-gnutls --enable-avresample --enable-avisynth --enable-ladspa --enable-libbluray --enable-libbs2b --enable-libcaca --enable-libcdio --enable-libflite --enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-libgme --enable-libgsm --enable-libmodplug --enable-libopenjpeg --enable-libpulse --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libssh --enable-libtwolame --enable-libvpx --enable-libwavpack --enable-libwebp --enable-libzvbi --enable-openal --enable-opencl --enable-opengl --enable-libdc1394 --enable-libiec61883 --enable-libzmq --enable-frei0r --enable-libopencv --enable-pthreads --enable-version3 --enable-hardcoded-tables --cc=cc --cxx=g++ \
    --enable-librtmp --enable-libopus --enable-libshine --enable-libx265 --enable-libxvid --enable-libx264 --enable-libass --enable-libfdk-aac --enable-libtheora --enable-libvorbis --enable-libmp3lame \
    && make -j2 && make install && make distclean && hash -r \
    && echo "$HOME/ffmpeg_build/lib" >> /etc/ld.so.conf.d/ffmpeg.conf && ldconfig \
    && ffmpeg -version