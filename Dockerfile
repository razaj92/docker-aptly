FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive
ENV APTLY_VERSION 1.3.0

# Install aptly and required tools
RUN \
apt-get -q update \
&& apt-get -y install \
  bash-completion \
  bzip2           \
  gnupg1          \
  gpgv            \
  gpgv1           \
  graphviz        \
  gpg             \
  wget            \
  xz-utils        \
  ubuntu-archive-keyring \
&& echo "deb http://repo.aptly.info/ squeeze main" > /etc/apt/sources.list.d/aptly.list \
&& apt-get --allow-unauthenticated update \
&& apt-get --allow-unauthenticated -y install aptly=${APTLY_VERSION} \
&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY files/aptly.conf /etc/aptly.conf
COPY files/entrypoint.sh /entrypoint.sh

RUN \
chmod +x /entrypoint.sh \
&& groupadd --system -g 501 aptly \
&& useradd --system --shell /bin/bash -u 501 -g aptly -d /var/lib/aptly -m aptly 1>/dev/null 2>/dev/null

USER 501:501

VOLUME ["/var/lib/aptly"]
EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bash"]
