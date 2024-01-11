# Define base image.
# FROM nvidia/cudagl:11.3.1-devel
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04
# FROM 763104351884.dkr.ecr.us-west-2.amazonaws.com/pytorch-training:1.12.1-gpu-py38-cu113-ubuntu20.04-sagemaker

# Set environment variables.
## Set non-interactive to prevent asking for user inputs blocking image creation.
ENV DEBIAN_FRONTEND=noninteractive
## Set timezone as it is required by some packages.
ENV TZ=America/Vancouver
## CUDA architectures, required by tiny-cuda-nn.
ENV TCNN_CUDA_ARCHITECTURES=86
## CUDA Home, required to find CUDA in some packages.
ENV CUDA_HOME="/usr/local/cuda"

# Install required apt packages.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ffmpeg \
    git \
    libatlas-base-dev \
    libboost-filesystem-dev \
    libboost-graph-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-test-dev \
    libcgal-dev \
    libeigen3-dev \
    libfreeimage-dev \
    libgflags-dev \
    libglew-dev \
    libgoogle-glog-dev \
    libmetis-dev \
    libprotobuf-dev \
    libqt5opengl5-dev \
    libsuitesparse-dev \
    nano \
    protobuf-compiler \
    # python3.8-dev \
    libpython3-dev \
    python3-pip \
    qtbase5-dev \
    wget \
    sudo

# # Install GLOG (required by ceres).
# RUN git clone --branch v0.6.0 https://github.com/google/glog.git --single-branch && \
#     cd glog && \
#     mkdir build && \
#     cd build && \
#     cmake .. && \
#     make -j && \
#     make install && \
#     cd ../.. && \
#     rm -r glog
# # Add glog path to LD_LIBRARY_PATH.
# ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/lib"
#
# # Install Ceres-solver (required by colmap).
# RUN git clone --branch 2.1.0 https://ceres-solver.googlesource.com/ceres-solver.git --single-branch && \
#     cd ceres-solver && \
#     git checkout $(git describe --tags) && \
#     mkdir build && \
#     cd build && \
#     cmake .. -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF && \
#     make -j && \
#     make install && \
#     cd ../.. && \
#     rm -r ceres-solver
#
# # Install colmap.
# RUN git clone --branch 3.7 https://github.com/colmap/colmap.git --single-branch && \
#     cd colmap && \
#     mkdir build && \
#     cd build && \
#     cmake .. && \
#     make -j && \
#     make install && \
#     cd ../.. && \
#     rm -r colmap

# # Create non root user and setup environment.
# RUN useradd -m -d /home/user -u 1000 user
#
# # Switch to new uer and workdir.
# USER 1000:1000
# WORKDIR /home/user
#
# # Add local user binary folder to PATH variable.
# ENV PATH="${PATH}:/home/user/.local/bin"

# # Upgrade pip and install packages.
RUN pip3 install --upgrade pip setuptools pathtools promise
# Install pytorch and submodules.
RUN pip3 install --ignore-installed torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113
# Install tynyCUDNN.
RUN pip3 install "git+https://github.com/NVlabs/tiny-cuda-nn.git#subdirectory=bindings/torch"

# Copy nerfstudio folder and give ownership to user.
# ADD . /home/user/sdfstudio
# USER root
# RUN chown -R user:user /home/user/sdfstudio
# USER 1000:1000

# # Change working directory
# WORKDIR /home/user/sdfstudio

ADD . /sdfstudio
WORKDIR /sdfstudio

RUN python3 -m pip install -e .

SHELL ["/bin/bash", "-c"]

CMD ns-install-cli && /bin/bash

# RUN ns-install-cli
# CMD /bin/bash
