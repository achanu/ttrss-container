FROM quay.io/centos/centos:stream AS micro-build

RUN \
  mkdir -p /rootfs && \
  dnf install -y \
    --installroot /rootfs --releasever 8 \
    --setopt install_weak_deps=false --nodocs \
    coreutils-single \
    glibc-minimal-langpack \
    setup \
    openssl \
  && \
  dnf -y module enable \
    --installroot /rootfs \
    php:8.0 \
  && \
  dnf install -y \
    --installroot /rootfs \
    --setopt install_weak_deps=false --nodocs \
    php-gd \
    php-intl \
    php-json \
    php-mbstring \
    php-opcache \
    php-pgsql \
    php-xmlrpc \
    nginx-filesystem \
    git-core \
    php-cli \
    php-curl \
    php-pecl-zip \
    php-process \
    httpd-filesystem \
  && \
  rm -rf \
    /rootfs/var/cache/* \
    /rootfs/var/lib/{yum,dnf} \
    /rootfs/var/log/{yum,dnf}*


FROM scratch AS ttrss-micro
LABEL maintainer="Alexandre Chanu <alexandre.chanu@gmail.com>"

COPY --from=micro-build /rootfs/ /

USER 999
CMD ["/usr/bin/php", "/usr/share/nginx/html/update_daemon2.php", "--log-level", "INFO"]

VOLUME /usr/share/nginx/html
