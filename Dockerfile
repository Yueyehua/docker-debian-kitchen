FROM debian:jessie
MAINTAINER Richard Delaplace "rdelaplace@yueyehua.net"
LABEL version="1.0.1"

# Apt update and install dependencies
RUN \
  apt-get -qq update && \
  apt-get -qq dist-upgrade -y && \
  apt-get -qq install -y iproute sudo less vim nano tree curl git && \
  apt-get -qq install -y autoconf bison build-essential libssl-dev \
    libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev \
    libgdbm3 libgdbm-dev && \
  apt-get -qq install -y apt-transport-https ca-certificates \
    software-properties-common;

# Install Ruby 2.4.0
ENV _RUBY=ruby-2.4.0 _RUBY_VERS=2.4
RUN \
  cd /tmp && \
  curl https://cache.ruby-lang.org/pub/ruby/${_RUBY_VERS}/${_RUBY}.tar.gz | \
    tar xzf - && \
  cd /tmp/${_RUBY} && \
  ./configure \
    --enable-shared \
    --disable-install-doc \
    --disable-install-rdoc \
    --disable-install-capi > /dev/null && \
  make -j > /dev/null && \
  make install > /dev/null && \
  cd && \
  rm -rf /tmp/${_RUBY};

# Install Python
RUN \
  apt-get -qq install -y python3 python3-pip;

# Add Apt repositories
RUN \
  curl -fsSL https://apt.dockerproject.org/gpg | apt-key add - && \
  add-apt-repository \
    "deb https://apt.dockerproject.org/repo/ debian-jessie main" && \
  curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc | \
    apt-key add - && \
  curl -fsSL https://www.virtualbox.org/download/oracle_vbox.asc | \
    apt-key add - && \
  add-apt-repository \
    'deb http://download.virtualbox.org/virtualbox/debian jessie contrib' && \
  apt-get -qq update;

# Install docker, vagrant, chef, puppet and ansible with lint tools
RUN \
  apt-get -qq install -y docker-engine virtualbox-5.1 vagrant \
    puppet puppet-lint && \
  gem install -q --no-rdoc --no-ri --no-format-executable --no-user-install \
    chef-dk foodcritic rubocop yaml-lint travis && \
  pip3 install ansible ansible-lint pylint;

# Install other tools for test purpose
RUN \
  apt-get -qq install -y snmp traceroute nmap

# Clean all
RUN \
  apt-get -qq clean autoclean;

# Install gems
RUN \
  gem install -q --no-rdoc --no-ri --no-format-executable --no-user-install \
    berkshelf bundler busser busser-serverspec serverspec webmock;

# Install test-kitchen
RUN \
  gem install -q --no-rdoc --no-ri --no-format-executable --no-user-install \
    test-kitchen \
    kitchen-puppet \
    kitchen-ansible \
    kitchen-docker_cli \
    kitchen-vagrant;

# Mask failing services
RUN \
  systemctl mask -- \
    sys-fs-fuse-connections.mount \
    dev-hugepages.mount \
    systemd-tmpfiles-setup.service;

VOLUME ["/sys/fs/cgroup", "/var/run/docker.sock", "/run", "/run/lock"]
CMD  ["/lib/systemd/systemd"]
