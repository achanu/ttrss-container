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
  cp -v /etc/yum.repos.d/*.repo /rootfs/etc/yum.repos.d/ && \
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
    php-xmlrpc \
    nginx-filesystem \
    git-core \
    php-fpm \
    php-ldap \
  && \
  dnf clean all && \
  rm -rf /rootfs/var/cache/* && \
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
    -e '/^listen = / s#/run/php-fpm/www.sock#9000#g' \
    -e '/^user = / s#^#;#g' \
    -e '/^group = / s#^#;#g' \
    /etc/php-fpm.d/www.conf

USER nginx
CMD ["/usr/sbin/php-fpm", "-F"]

VOLUME /usr/share/nginx/html
EXPOSE 9000/tcp
