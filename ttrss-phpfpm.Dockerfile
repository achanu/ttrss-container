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
    php:7.4 \
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
    php-xml \
    nginx-filesystem \
    git-core \
    php-fpm \
    php-ldap \
  && \
  rm -rf \
    /rootfs/var/cache/* \
    /rootfs/var/lib/{yum,dnf} \
    /rootfs/var/log/{yum,dnf}* \
  && \
  mkdir -v /rootfs/run/php-fpm && \
  sed -i \
    -e '/^nginx:/ s#/sbin/nologin#/bin/bash#g' \
    /rootfs/etc/passwd


FROM scratch AS ttrss-micro
LABEL maintainer="Alexandre Chanu <alexandre.chanu@gmail.com>"

COPY --from=micro-build /rootfs/ /

RUN \
  chown -c nginx /run/php-fpm /var/log/php-fpm && \
  sed -i \
    -e '/^daemonize / s#[[:graph:]]*$#no#' \
    -e '/^error_log / s#[[:graph:]]*$#/proc/1/fd/2#' \
    /etc/php-fpm.conf \
  && \
  sed -i \
    -e '/^listen = / s#[[:graph:]]*$#9000#' \
    -e '/^user = / s#^#;#g' \
    -e '/^group = / s#^#;#g' \
    -e '/^access.log / s#[[:graph:]]*$#/proc/1/fd/1#' \
    /etc/php-fpm.d/www.conf

USER 999
CMD ["/usr/sbin/php-fpm"]

VOLUME /usr/share/nginx/html
EXPOSE 9000/tcp
