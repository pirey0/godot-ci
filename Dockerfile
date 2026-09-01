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

# Software Vulkan driver (Mesa lavapipe) plus a virtual X server, so a
# Godot editor can stand up a real RenderingDevice/RendererSceneRenderRD
# without a GPU. Needed for the Shader Baker export feature.
#
# lavapipe alone is NOT enough: DisplayServerHeadless (used by --headless)
# ignores whatever --rendering-driver is passed and unconditionally calls
# RasterizerDummy::make_current() (servers/display/display_server_headless.h)
# -- it can never create a RenderingDevice, by hardcoded design, regardless
# of environment. The export step that needs Shader Baker must instead run
# under a real DisplayServer (X11) via xvfb-run, with --rendering-driver
# vulkan explicit and --headless omitted; DisplayServerX11 actually honors
# that driver choice and hands off to lavapipe.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libvulkan1 \
    mesa-vulkan-drivers \
    vulkan-tools \
    xvfb \
    && rm -rf /var/lib/apt/lists/* \
    && vulkaninfo --summary

# Add and set up action script
USER root
ADD action.sh /action.sh
RUN chmod +x action.sh

ENTRYPOINT ["/action.sh"]
