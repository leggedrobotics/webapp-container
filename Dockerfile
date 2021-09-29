# syntax = docker/dockerfile:1.0-experimental
FROM alpine:3.13 AS base

RUN --mount=type=cache,target=/etc/apk/cache apk --update-cache add ca-certificates \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN --mount=type=cache,target=/etc/apk/cache apk --update-cache add \
  php \
  php-fpm \
  php-json \
  php-dom \
  php-fileinfo \
  php-mbstring \
  php-openssl \
  php-phar \
  php-tokenizer \
  php-xml \
  php-xmlwriter \
  php-session \
  php-pdo \
  php-sqlite3 \
  php-pdo_sqlite \
  php-mysqli \
  php-pdo_mysql \
  php-pgsql \
  php-pdo_pgsql \
  nginx \
  redis \
  supervisor \
  su-exec \
  composer \
  sudo \
  shadow \
  py3-setuptools

RUN echo "app ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/app
RUN echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
RUN echo "* * * * * su-exec php-fpm php /opt/artisan schedule:run" >> /etc/crontabs/root

ARG UID=1000
ARG GID=1000
RUN adduser -D app \
  && chown app:app /opt \
  && adduser -SDH php-fpm \
  && usermod -g app php-fpm \
  && usermod -g app nginx \
  && usermod -u $UID app \
  && groupmod -g $GID app

WORKDIR /opt

COPY docker/entrypoint.sh /
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
ARG NGINX_CONF=standalone.conf
COPY docker/nginx/${NGINX_CONF} /etc/nginx/conf.d/default.conf
COPY docker/php/php-fpm.d/ /etc/php7/php-fpm.d/
COPY docker/supervisord/ /etc/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]

# Build xdebug in a separate stage to avoid polluting the development image
FROM alpine:edge AS xdebug-builder
RUN --mount=type=cache,target=/etc/apk/cache apk --update-cache add ca-certificates \
  && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN --mount=type=cache,target=/etc/apk/cache apk add \
  php \
  php7-pear \
  php7-dev \
  php-openssl \
  gcc \
  musl-dev \
  make \
  && pecl install xdebug

FROM base AS development

RUN --mount=type=cache,target=/etc/apk/cache apk add \
  vim \
  tree \
  sqlite
COPY --from=xdebug-builder /usr/lib/php7/modules/xdebug.so /usr/lib/php7/modules/
RUN echo "zend_extension=/usr/lib/php7/modules/xdebug.so" >> /etc/php7/php.ini
RUN echo "xdebug.mode=debug,develop" >> /etc/php7/conf.d/90_xdebug.ini \
 && echo "xdebug.idekey=CODE_ACCESS" >> /etc/php7/conf.d/90_xdebug.ini \
 && echo "xdebug.discover_client_host=true" >> /etc/php7/conf.d/90_xdebug.ini

