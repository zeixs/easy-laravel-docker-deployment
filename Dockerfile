FROM php:8.1.20-fpm-alpine3.17

LABEL Maintainer="Jose Quintana <joseluisq.net>" \
    Description="PHP-FPM v8.1 with essential extensions on top of Alpine Linux."

# Composer - https://getcomposer.org/download/
ARG COMPOSER_VERSION="2.5.8"
ARG COMPOSER_SUM="f07934fad44f9048c0dc875a506cca31cc2794d6aebfc1867f3b1fbf48dce2c5"

# Swoole - https://github.com/swoole/swoole-src
ARG SWOOLE_VERSION="5.0.3"

# Phalcon - https://github.com/phalcon/cphalcon
ARG PHALCON_VERSION="5.2.1"

# Install dependencies
RUN set -eux \
    && apk add --no-cache \
        c-client \
        ca-certificates \
        freetds \
        freetype \
        gettext \
        gmp \
        icu-libs \
        imagemagick \
        imap \
        libffi \
        libgmpxx \
        libintl \
        libjpeg-turbo \
        libpng \
        libpq \
        librdkafka \
        libssh2 \
        libstdc++ \
        libtool \
        libxpm \
        libxslt \
        libzip \
        make \
        rabbitmq-c \
        tidyhtml \
        tzdata \
        unixodbc \
        vips \
        yaml

#############################################
### Install and enable PHP extensions
#############################################

# Development dependencies
RUN set -eux \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        bzip2-dev \
        cmake \
        curl-dev \
        freetds-dev \
        freetype-dev \
        g++ \
        gcc \
        gettext-dev \
        git \
        gmp-dev \
        icu-dev \
        imagemagick-dev \
        imap-dev \
        krb5-dev \
        libc-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        librdkafka-dev \
        libssh2-dev \
        libwebp-dev \
        libxml2-dev \
        libxpm-dev \
        libxslt-dev \
        libzip-dev \
        openssl-dev \
        # pcre-dev \
        # pkgconf \
        # postgresql-dev \
        rabbitmq-c-dev \
        tidyhtml-dev \
        unixodbc-dev \
        vips-dev \
        # yaml-dev \
        zlib-dev \
\
# Workaround for rabbitmq linking issue
    && ln -s /usr/lib /usr/local/lib64 \
\
# Enable ffi if it exists
    && set -eux \
    && if [ -f /usr/local/etc/php/conf.d/docker-php-ext-ffi.ini ]; then \
        echo "ffi.enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-ffi.ini; \
    fi \
\
################################
# Install PHP extensions
################################
\
# Install gd
    && ln -s /usr/lib/$(apk --print-arch)-linux-gnu/libXpm.* /usr/lib/ \
    && docker-php-ext-configure gd \
        --enable-gd \
        --with-webp \
        --with-jpeg \
        --with-xpm \
        --with-freetype \
        --enable-gd-jis-conv \
    && docker-php-ext-install -j$(nproc) gd \
    && true \
\
# Install amqp
#     && pecl install amqp \
#     && docker-php-ext-enable amqp \
#     && true \
# \
# Install apcu
#     && pecl install apcu \
#     && docker-php-ext-enable apcu \
#     && true \
# \
# Install gettext
    && docker-php-ext-install -j$(nproc) gettext \
    && true \
\
# Install gmp
#     && docker-php-ext-install -j$(nproc) gmp \
#     && true \
# \
# Install bcmath
#     && docker-php-ext-install -j$(nproc) bcmath \
#     && true \
# \
# Install bz2
#     && docker-php-ext-install -j$(nproc) bz2 \
#     && true \
# \
# Install exif
    && docker-php-ext-install -j$(nproc) exif \
    && true \
\
# Install imap
#     && docker-php-ext-configure imap --with-kerberos --with-imap-ssl --with-imap \
#     && docker-php-ext-install -j$(nproc) imap \
#     && true \
# \
# Install imagick
#     && pecl install imagick \
#     && docker-php-ext-enable imagick \
#     && true \
# \
# Install intl
    && docker-php-ext-install -j$(nproc) intl \
    && true \
\
## Install mcrypt
## DEPRECATED: This dependency is dead so move to `libsodium` or `openssl`
##     && pecl install mcrypt-1.0.4 \
##     && docker-php-ext-enable mcrypt \
##     && true \
## \
# Install memcache
    && pecl install memcache \
    && docker-php-ext-enable memcache \
    && true \
\
# Install mongodb
#     && pecl install mongodb \
#     && docker-php-ext-enable mongodb \
#     && true \
# \
# Install mysqli
#     && docker-php-ext-install -j$(nproc) mysqli \
#     && true \
# \
# Install oauth
#     && pecl install oauth \
#     && docker-php-ext-enable oauth \
#     && true \
# \
# Install opcache
    && docker-php-ext-install -j$(nproc) opcache \
    && true \
\
# Install pdo_mysql
    && docker-php-ext-configure pdo_mysql --with-zlib-dir=/usr \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && true \
\
# Install pdo_dblib
#     && docker-php-ext-install -j$(nproc) pdo_dblib \
#     && true \
# \
# Install pcntl
    && docker-php-ext-install -j$(nproc) pcntl \
    && true \
\
# Install phalcon
#     && git clone --depth=1 --branch=v${PHALCON_VERSION} https://github.com/phalcon/cphalcon.git \
#     && cd cphalcon/build \
#     && sh ./install \
#     && docker-php-ext-enable phalcon \
#     && true \
# \
# Install pdo_pgsql
#     && docker-php-ext-install -j$(nproc) pdo_pgsql \
#     && true \
# \
# Install pgsql
#     && docker-php-ext-install -j$(nproc) pgsql \
#     && true \
# \
# ONLY 64-bit targets
    && if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "aarch64" ]; then \
    # Install sqlsrv
        pecl install sqlsrv; \
        docker-php-ext-enable sqlsrv; \
        true; \
    # Install pdo_sqlsrv
        pecl install pdo_sqlsrv; \
        docker-php-ext-enable pdo_sqlsrv; \
        true; \
    fi \
\
# Install psr
    && pecl install psr \
    && docker-php-ext-enable psr \
    && true \
\
# Install redis
#     && pecl install redis \
#     && docker-php-ext-enable redis \
#     && true \
# \
# Install rdkafka
#     && pecl install rdkafka \
#     && docker-php-ext-enable rdkafka \
#     && true \
# \
# Install soap
#     && docker-php-ext-install -j$(nproc) soap \
#     && true \
# \
# Install ssh2
#     && pecl install ssh2-1.3.1 \
#     && docker-php-ext-enable ssh2 \
#     && true \
# \
# Install sockets, sysvmsg, sysvsem, sysvshm (also needed by swoole)
#     && CFLAGS="${CFLAGS:=} -D_GNU_SOURCE" docker-php-ext-install -j$(nproc) \
#         sockets \
#         sysvmsg \
#         sysvsem \
#         sysvshm \
#     && docker-php-source extract \
#     && true \
# \
# Install swoole
#     && mkdir /usr/src/php/ext/swoole \
#     && curl -Lo swoole.tar.gz https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz \
#     && tar xfz swoole.tar.gz --strip-components=1 -C /usr/src/php/ext/swoole \
#     && docker-php-ext-configure swoole \
#             --enable-mysqlnd \
#             --enable-sockets \
#             --enable-openssl \
#             --enable-swoole-curl \
#     && docker-php-ext-install -j$(nproc) swoole \
#     && rm -rf swoole.tar.gz $HOME/.composer/*-old.phar \
#     && docker-php-ext-enable swoole \
#     && true \
# \
# Install tidy
#     && docker-php-ext-install -j$(nproc) tidy \
#     && true \
# \
# Install xsl
    && docker-php-ext-install -j$(nproc) xsl \
    && true \
\
# Install yaml
#     && pecl install yaml \
#     && docker-php-ext-enable yaml \
#     && true \
# \
# Install vips
#     && pecl install vips \
#     && docker-php-ext-enable vips \
#     && true \
# \
# Install zip
    && docker-php-ext-configure zip --with-zip \
    && docker-php-ext-install -j$(nproc) zip \
    && true \
\
# Clean up build packages
    && docker-php-source delete \
    && apk del .build-deps \
    && true

RUN set -eux \
# Fix php.ini settings for enabled extensions
    && chmod +x "$(php -r 'echo ini_get("extension_dir");')"/* \
# Shrink binaries
    && (find /usr/local/bin -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && (find /usr/local/lib -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && (find /usr/local/sbin -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) \
    && true

# Install Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "copy('https://composer.github.io/installer.sig', 'signature');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === trim(file_get_contents('signature'))) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');" \
RUN echo "Done downloading composer"

# Copy PHP-FPM configuration files
COPY ./Docker/8.1-fpm/php-fpm.tmpl.conf /var/data/php-fpm/php-fpm.tmpl.conf
COPY ./Docker/8.1-fpm/www.tmpl.conf /var/data/php-fpm/www.tmpl.conf
COPY ./Docker/8.1-fpm/php.tmpl.ini /var/data/php-fpm/default-php.tmpl.ini

RUN set -eux \
# PHP-FPM templates directory
    && mkdir -p /var/data/php-fpm \
# Remove few PHP-FPM default config files
    && rm -rf /usr/local/etc/php-fpm.d/zz-docker.conf \
    && rm -rf /usr/local/etc/php-fpm.d/docker.conf \
\
# Perform PHP-FPM testing
    && echo "Performing PHP-FPM tests..." \
    && echo "date.timezone=UTC" > /usr/local/etc/php/php.ini \
    && php -v | grep -oE 'PHP\s[.0-9]+' | grep -oE '[.0-9]+' | grep '^8.1' \
    && /usr/local/sbin/php-fpm --test \
\
    && PHP_ERROR="$( php -v 2>&1 1>/dev/null )" \
    && if [ -n "${PHP_ERROR}" ]; then echo "${PHP_ERROR}"; false; fi \
    && PHP_ERROR="$( php -i 2>&1 1>/dev/null )" \
    && if [ -n "${PHP_ERROR}" ]; then echo "${PHP_ERROR}"; false; fi \
\
    && PHP_FPM_ERROR="$( php-fpm -v 2>&1 1>/dev/null )" \
    && if [ -n "${PHP_FPM_ERROR}" ]; then echo "${PHP_FPM_ERROR}"; false; fi \
    && PHP_FPM_ERROR="$( php-fpm -i 2>&1 1>/dev/null )" \
    && if [ -n "${PHP_FPM_ERROR}" ]; then echo "${PHP_FPM_ERROR}"; false; fi \
    && rm -f /usr/local/etc/php/php.ini \
    && true

# Copy util scripts
COPY ./Docker/8.1-fpm/envsubst.sh /envsubst.sh
COPY ./Docker/8.1-fpm/entrypoint.sh /entrypoint.sh

STOPSIGNAL SIGQUIT

# Metadata
LABEL org.opencontainers.image.vendor="Jose Quintana" \
    org.opencontainers.image.url="https://github.com/joseluisq/alpine-php-fpm" \
    org.opencontainers.image.title="PHP-FPM v8.1 Alpine" \
    org.opencontainers.image.description="PHP-FPM v8.1 with essential extensions on top of Alpine Linux." \
    org.opencontainers.image.version="$PHP_VERSION" \
    org.opencontainers.image.documentation="https://github.com/joseluisq/alpine-php-fpm"

# Install packages
RUN apk update && \
    apk add --no-cache \
    lighttpd \
    openssl \
    curl && \
    rm -rf /var/cache/apk/*

# Create lighttpd ssl directory and generate self signed cert
# RUN mkdir /etc/lighttpd/ssl/ && \
# 	openssl req -x509 -newkey rsa:4096 -keyout /tmp/key.pem -out /tmp/cert.pem -days 365 -subj '/CN=localhost' -nodes -sha256 && \
# 	cat /tmp/key.pem /tmp/cert.pem > /etc/lighttpd/ssl/localhost.pem && \
# 	rm /tmp/key.pem /tmp/cert.pem && \
# 	chmod 400 /etc/lighttpd/ssl/localhost.pem

# Copy lighttpd config files. At this point it is all default except
# including a custom ssl.conf in lighttpd.conf.
COPY ./Docker/config/*.conf /etc/lighttpd/

# change this to suit your directory
COPY . /var/www/andropedia 

RUN rm composer.lock
RUN composer update

RUN apk add npm
RUN npm install --global yarn
RUN yarn
RUN yarn production
RUN yarn tailwind-production

# Check every minute if lighttpd responds within 1 second and update
# container health status accordingly.
HEALTHCHECK --interval=1m --timeout=1s \
  CMD curl -f http://localhost/ || exit 1

# Expose http(s) ports
EXPOSE 80 443

# Make configuration path and webroot a volume
VOLUME /etc/lighttpd/
VOLUME /var/www/

CMD php-fpm -D && lighttpd -D -f /etc/lighttpd/lighttpd.conf