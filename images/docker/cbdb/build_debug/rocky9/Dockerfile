# --------------------------------------------------------------------
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements. See the NOTICE file distributed
# with this work for additional information regarding copyright
# ownership. The ASF licenses this file to You under the Apache
# License, Version 2.0 (the "License"); you may not use this file
# except in compliance with the License. You may obtain a copy of the
# License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#
# --------------------------------------------------------------------
#
# Apache Cloudberry (incubating) is an effort undergoing incubation at
# the Apache Software Foundation (ASF), sponsored by the Apache
# Incubator PMC.
#
# Incubation is required of all newly accepted projects until a
# further review indicates that the infrastructure, communications,
# and decision making process have stabilized in a manner consistent
# with other successful ASF projects.
#
# While incubation status is not necessarily a reflection of the
# completeness or stability of the code, it does indicate that the
# project has yet to be fully endorsed by the ASF.
#
# --------------------------------------------------------------------
# Dockerfile for Apache Cloudberry Build Environment
# --------------------------------------------------------------------
# This Dockerfile sets up a Rocky Linux 9-based container for building
# and developing Apache Cloudberry. It installs necessary system
# utilities, development tools, and configures the environment for SSH
# access and systemd support.
#
# Key Features:
# - Locale setup for en_US.UTF-8
# - SSH daemon setup for remote access
# - Essential development tools and libraries installation
# - User configuration for 'gpadmin' with sudo privileges
#
# Usage:
#   docker build -t cloudberry-db-env .
#   docker run -h cdw -it cloudberry-db-env
# --------------------------------------------------------------------

# Base image: Rocky Linux 9
FROM rockylinux/rockylinux:9

# Argument for configuring the timezone
ARG TIMEZONE_VAR="America/Los_Angeles"

# Environment variables for locale and user
ENV container=docker
ENV LANG=en_US.UTF-8
ENV USER=gpadmin

# --------------------------------------------------------------------
# Install Development Tools and Utilities
# --------------------------------------------------------------------
# Install various development tools, system utilities, and libraries
# required for building and running Apache Cloudberry.
# - EPEL repository is enabled for additional packages.
# - Cleanup steps are added to reduce image size after installation.
# --------------------------------------------------------------------
RUN dnf makecache && \
    dnf install -y \
        epel-release \
        git && \
    dnf config-manager --disable epel-cisco-openh264 && \
    dnf makecache && \
    dnf config-manager --disable epel && \
    dnf install -y --enablerepo=epel \
        the_silver_searcher \
        bat \
        htop && \
    dnf install -y \
        bison \
        cmake3 \
        ed \
        flex \
        gcc \
        gcc-c++ \
        glibc-langpack-en \
        glibc-locale-source \
        initscripts \
        iproute \
        less \
        m4 \
        net-tools \
        openssh-clients \
        openssh-server \
        perl \
        rpm-build \
        rpmdevtools \
        rsync \
        sudo \
        tar \
        unzip \
        util-linux-ng \
        wget \
        sshpass \
        which && \
    dnf install -y \
        apr-devel \
        bzip2-devel \
        java-11-openjdk \
        java-11-openjdk-devel \
        krb5-devel \
        libcurl-devel \
        libevent-devel \
        libxml2-devel \
        libuuid-devel \
        libzstd-devel \
        lz4 \
        lz4-devel \
        openldap-devel \
        openssl-devel \
        pam-devel \
        perl-ExtUtils-Embed \
        perl-Test-Simple \
        perl-core \
        python3-devel \
        python3-pytest \
        readline-devel \
        zlib-devel && \
    dnf install -y --enablerepo=crb \
        libuv-devel \
        libyaml-devel \
        perl-IPC-Run && \
    dnf clean all && \
    cd && XERCES_LATEST_RELEASE=3.3.0 && \
    wget -nv "https://archive.apache.org/dist/xerces/c/3/sources/xerces-c-${XERCES_LATEST_RELEASE}.tar.gz" && \
    echo "$(curl -sL https://archive.apache.org/dist/xerces/c/3/sources/xerces-c-${XERCES_LATEST_RELEASE}.tar.gz.sha256)" | sha256sum -c - && \
    tar xf "xerces-c-${XERCES_LATEST_RELEASE}.tar.gz"; rm "xerces-c-${XERCES_LATEST_RELEASE}.tar.gz" && \
    cd xerces-c-${XERCES_LATEST_RELEASE} && \
    ./configure --prefix=/usr/local/xerces-c && \
    make -j$(nproc) && \
    make install -C ~/xerces-c-${XERCES_LATEST_RELEASE} && \
    rm -rf ~/xerces-c* && \
    cd && GO_VERSION="go1.23.2" && \
    GO_VERSION="go1.23.2" && \
    GO_SHA256="542d3c1705f1c6a1c5a80d5dc62e2e45171af291e755d591c5e6531ef63b454e" && \
    GO_URL="https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" && \
    wget -nv "${GO_URL}" && \
    echo "${GO_SHA256}  ${GO_VERSION}.linux-amd64.tar.gz" | sha256sum -c - && \
    tar xf "${GO_VERSION}.linux-amd64.tar.gz" && \
    mv go "/usr/local/${GO_VERSION}" && \
    ln -s "/usr/local/${GO_VERSION}" /usr/local/go && \
    rm -f "${GO_VERSION}.linux-amd64.tar.gz" && \
    echo 'export PATH=$PATH:/usr/local/go/bin' | tee -a /etc/profile.d/go.sh > /dev/null

# --------------------------------------------------------------------
# Copy Configuration Files and Setup the Environment
# --------------------------------------------------------------------
# - Copy custom configuration files from the build context to /tmp/.
# - Apply custom system limits and timezone.
# - Create and configure the 'gpadmin' user with sudo privileges.
# - Set up SSH for password-based authentication.
# - Generate locale and set the default locale to en_US.UTF-8.
# --------------------------------------------------------------------

# Copy configuration files from their respective locations
COPY ./configs/* /tmp/

RUN cp /tmp/90-cbdb-limits /etc/security/limits.d/90-cbdb-limits && \
    sed -i.bak -r 's/^(session\s+required\s+pam_limits.so)/#\1/' /etc/pam.d/* && \
    cat /usr/share/zoneinfo/${TIMEZONE_VAR} > /etc/localtime && \
    chmod 777 /tmp/init_system.sh && \
    /usr/sbin/groupadd gpadmin && \
    /usr/sbin/useradd gpadmin -g gpadmin -G wheel && \
    setcap cap_net_raw+ep /usr/bin/ping && \
    echo 'gpadmin ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/90-gpadmin && \
    echo -e '\n# Add Cloudberry entries\nif [ -f /usr/local/cloudberry-db/greenplum_path.sh ]; then\n  source /usr/local/cloudberry-db/greenplum_path.sh\nfi' >> /home/gpadmin/.bashrc && \
    ssh-keygen -A && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    echo "LANG=en_US.UTF-8" | tee /etc/locale.conf && \
    dnf clean all  # Final cleanup to remove unnecessary files

# Install testinfra via pip
RUN pip3 install pytest-testinfra

# Copying test files into the container
COPY ./tests /tests

# --------------------------------------------------------------------
# Build and Install Cloudberry
# --------------------------------------------------------------------
# Clone, configure, build, and install Cloudberry as the gpadmin user
# --------------------------------------------------------------------

# Switch to gpadmin user for Cloudberry operations
USER gpadmin
WORKDIR /home/gpadmin

# Clone Cloudberry and set up build environment
RUN git clone https://github.com/edespino/cloudberry.git ~/cloudberry && \
    sudo rm -rf /usr/local/cloudberry-db && \
    sudo chmod a+w /usr/local && \
    mkdir -p /usr/local/cloudberry-db/lib && \
    sudo cp /usr/local/xerces-c/lib/libxerces-c.so \
           /usr/local/xerces-c/lib/libxerces-c-3.*.so \
           /usr/local/cloudberry-db/lib && \
    sudo chown -R gpadmin:gpadmin /usr/local/cloudberry-db

# Configure and build Cloudberry
ENV LD_LIBRARY_PATH=/usr/local/cloudberry-db/lib:${LD_LIBRARY_PATH}
RUN cd ~/cloudberry && \
    ./configure --prefix=/usr/local/cloudberry-db \
                --disable-external-fts \
                --enable-cassert \
                --enable-debug-extensions \
                --enable-gpcloud \
                --enable-ic-proxy \
                --enable-mapreduce \
                --enable-orafce \
                --enable-orca \
                --enable-pxf \
                --enable-tap-tests \
                --with-gssapi \
                --with-ldap \
                --with-libxml \
                --with-lz4 \
                --with-openssl \
                --with-pam \
                --with-perl \
                --with-pgport=5432 \
                --with-python \
                --with-pythonsrc-ext \
                --with-ssl=openssl \
                --with-openssl \
                --with-uuid=e2fs \
                --with-includes=/usr/local/xerces-c/include \
                --with-libraries=/usr/local/cloudberry-db/lib | tee configure-$(date "+%Y.%m.%d-%H.%M.%S").log && \
    make -j$(nproc) | tee make-$(date "+%Y.%m.%d-%H.%M.%S").log && \
    make -j$(nproc) -C contrib | tee make-contrib-$(date "+%Y.%m.%d-%H.%M.%S").log && \
    make install | tee make-install-$(date "+%Y.%m.%d-%H.%M.%S").log && \
    make install -C contrib | tee make-contrib-install-$(date "+%Y.%m.%d-%H.%M.%S").log


# Return to base configuration
WORKDIR /home/gpadmin

# --------------------------------------------------------------------
# Set the Default Command
# --------------------------------------------------------------------
# The container starts by running the init_system.sh script.
# The container also mounts the /sys/fs/cgroup volume for systemd compatibility.
# --------------------------------------------------------------------

VOLUME [ "/sys/fs/cgroup" ]
CMD ["bash","-c","/tmp/init_system.sh"]
