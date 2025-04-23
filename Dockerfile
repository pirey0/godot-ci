FROM ubuntu:jammy

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    git-lfs \
    unzip \
    wget \
    zip \
    adb \
    rsync \
    wine64 \
    osslsigncode \
    python3 \
    python3-pip \
    libatomic1 \
    libpulse-mainloop-glib0

# Install GCC 13 and set it as the default for making friends
RUN apt-get install -y software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y libstdc++6

RUN ln -s /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*

# Add i386 architecture and install 32-bit libraries
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y lib32gcc-s1 \
    && rm -rf /var/lib/apt/lists/*

# Add and set up action script
USER root
ADD action.sh /action.sh
RUN chmod +x action.sh

ENTRYPOINT ["/action.sh"]
