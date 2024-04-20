FROM ubuntu:16.04
RUN \
	apt update && \
	apt -y install software-properties-common && \
	add-apt-repository -y ppa:git-core/ppa
RUN \
	apt update && \
	apt -y install build-essential \
		autoconf \
		automake \
		libtool \
		cmake \
		gcc \
		g++ \
		binutils \
		patch \
		bzip2 \
		flex \
		make \
		gettext \
		pkg-config \
		unzip \
		zlib1g-dev \
		libc6-dev \
		subversion \
		libncurses5-dev \
		gawk \
		sharutils \
		curl \
		libxml-parser-perl \
		ocaml-nox \
		ocaml \
		ocaml-findlib \
		libpcre3-dev \
		binutils-gold \
		python-yaml \
		libgd-dev \
		multiarch-support \
		lib32ncurses5 \
		lib32z1 \
		libssl-dev \
		device-tree-compiler \
		u-boot-tools \
		vim \
		repo \
		wget \
		zip \
		quilt \
		libc6-dev-i386 \
		python3-pip \
		python-pip \
		ccache \
		openvswitch-switch \
		libfdt-dev \
		git \
		stow \
		python3-pydot \
		pigz \
		dropbear-bin \
		squashfs-tools \
		rsync

# Install kconfiglib required for menuconfig
RUN pip3 install 'pip==20.3.4'
RUN pip3 install kconfiglib
RUN pip3 install 'MarkupSafe<2.0.0' 'Jinja2<3.0.0'
RUN pip3 install pyyaml
RUN pip2 install 'pip==20.3.4'
RUN pip2 install 'requests<2.28' 'certifi<=2021.10.08' 'cmake==3.27.7'

# Install protobuf-3.14.0 from source
RUN mkdir -p /usr/src/protobuf
COPY protobuf-cpp-3.14.0.tar.gz /usr/src/protobuf/
RUN cd /usr/src/protobuf && \
    tar xvf protobuf-cpp-3.14.0.tar.gz && \
    cd protobuf-3.14.0 && \
    ./configure --prefix=/usr && make V=s -j $(nproc) && make V=s -j $(nproc) install

# Install protobuf-c-1.3.3 from source
RUN mkdir -p /usr/src/protobuf-c
COPY protobuf-c-1.3.3.tar.gz /usr/src/protobuf-c/
RUN cd /usr/src/protobuf-c && \
    tar xvf protobuf-c-1.3.3.tar.gz && \
    cd protobuf-c-1.3.3 && \
    ./configure --prefix=/usr && make V=s -j $(nproc) && make V=s -j $(nproc) install

SHELL [ "/bin/bash", "-c" ]
ENV SHELL=/bin/bash
ENV SDKMAN_DIR=/usr/local/sdkman
RUN curl -s "https://get.sdkman.io" | bash
RUN source "/usr/local/sdkman/bin/sdkman-init.sh" && \
	sdk install java 17.0.0-tem && \
	sdk install gradle 7.5

RUN apt install byacc

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
