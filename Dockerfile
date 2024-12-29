ARG UBUNTU_VERSION=16.04
ARG PYTHON_VERSION=3.8.20
ARG PYTHON_SHORT_VERSION=3.8

# ===================================
# Stage 1: Build Python from Source
# ===================================
FROM ubuntu:${UBUNTU_VERSION} AS builder

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
wget \
build-essential \
libssl-dev \
zlib1g-dev \
libncurses5-dev \
libffi-dev \
libsqlite3-dev \
libreadline-dev \
libtk8.6 \
libgdbm-dev \
ca-certificates \
xz-utils \
&& rm -rf /var/lib/apt/lists/*

# Download and extract Python source
WORKDIR /usr/src
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
&& tar xzf Python-${PYTHON_VERSION}.tgz \
&& rm Python-${PYTHON_VERSION}.tgz

# Compile and install Python
WORKDIR /usr/src/Python-${PYTHON_VERSION}
RUN ./configure --enable-optimizations \
&& make -j "$(nproc)" \
&& make altinstall

# ====================================
# Stage 2: Create Final Runtime Image
# ====================================
FROM ubuntu:${UBUNTU_VERSION}

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
libssl1.0.0 \
libncurses5 \
libffi6 \
zlib1g \
libsqlite3-0 \
libreadline7 \
libtk8.6 \
libgdbm-dev \
ca-certificates \
&& rm -rf /var/lib/apt/lists/*

# Copy Python binaries from builder stage
COPY --from=builder /usr/local/bin/python${PYTHON_SHORT_VERSION} /usr/local/bin/python${PYTHON_SHORT_VERSION}
COPY --from=builder /usr/local/lib/python${PYTHON_SHORT_VERSION} /usr/local/lib/python${PYTHON_SHORT_VERSION}
COPY --from=builder /usr/local/include/python${PYTHON_SHORT_VERSION} /usr/local/include/python${PYTHON_SHORT_VERSION}

# Ensure pip is installed and upgraded
RUN python${PYTHON_SHORT_VERSION} -m ensurepip --upgrade \
&& python${PYTHON_SHORT_VERSION} -m pip install --no-cache-dir --upgrade pip
