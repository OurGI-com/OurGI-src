#syntax=docker/dockerfile:1-experimental

FROM debian:buster-slim

RUN --mount=type=bind,source=files,target=/files \
    `#dirs` \
    mkdir -p /usr/local/nginx/sbin/ \
    && mkdir -p /usr/local/nginx/conf/lua_libs \
    && mkdir -p /usr/local/luajit/lib/ \
    && mkdir -p /usr/local/php73/sbin/ \
    && mkdir -p /usr/local/php73/bin/ \
    && mkdir -p /usr/local/php73/lib/ \
    && mkdir -p /usr/local/php73/etc/ \
    && mkdir -p /etc/ssl/certs/ \
    && mkdir -p /etc/wireguard/ \
    && addgroup nobody \
    \
    `#nginx(lua)` \
    && cp /files/usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx \
    && cp /files/usr/local/nginx/conf/mime.types /usr/local/nginx/conf/mime.types \
    && cp /files/usr/local/nginx/conf/fastcgi_params /usr/local/nginx/conf/fastcgi_params \
    && cp /files/usr/local/nginx/conf/fastcgi.conf /usr/local/nginx/conf/fastcgi.conf \
    && cp /files/usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf \
    && cp /files/usr/local/nginx/conf/lua_libs/*.lua /usr/local/nginx/conf/lua_libs/ \
    && cp -r /files/usr/local/nginx/wwwroot /usr/local/nginx/ \
    \
    `#nginx(lua) depens` \
    && cp /files/usr/local/luajit/lib/libluajit-5.1.so.2 /usr/local/luajit/lib/libluajit-5.1.so.2 \
    && cp /files/usr/lib/x86_64-linux-gnu/libssl.so.1.1 /usr/lib/x86_64-linux-gnu/libssl.so.1.1 \
    && cp /files/usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 \
    \
    `#fpm(php)` \
    && cp /files/usr/local/php73/sbin/php-fpm /usr/local/php73/sbin/php-fpm \
    && cp /files/usr/local/php73/bin/php /usr/local/php73/bin/php \
    && cp /files/usr/local/php73/lib/php.ini /usr/local/php73/lib/php.ini \
    && cp /files/usr/local/php73/etc/php-fpm.conf /usr/local/php73/etc/php-fpm.conf \
    && cp /files/etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt \
    \
    `#fpm(php) depends` \
    && cp /files/usr/lib/x86_64-linux-gnu/libargon2.so.1 /usr/lib/x86_64-linux-gnu/libargon2.so.1 \
    && cp /files/usr/lib/x86_64-linux-gnu/libpq.so.5 /usr/lib/x86_64-linux-gnu/libpq.so.5 \
    && cp /files/usr/lib/x86_64-linux-gnu/libsodium.so.23 /usr/lib/x86_64-linux-gnu/libsodium.so.23 \
    && cp /files/usr/lib/x86_64-linux-gnu/libgssapi_krb5.so.2 /usr/lib/x86_64-linux-gnu/libgssapi_krb5.so.2 \
    && cp /files/usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2 /usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2 \
    && cp /files/usr/lib/x86_64-linux-gnu/libkrb5.so.3 /usr/lib/x86_64-linux-gnu/libkrb5.so.3 \
    && cp /files/usr/lib/x86_64-linux-gnu/libk5crypto.so.3 /usr/lib/x86_64-linux-gnu/libk5crypto.so.3 \
    && cp /files/usr/lib/x86_64-linux-gnu/libkrb5support.so.0 /usr/lib/x86_64-linux-gnu/libkrb5support.so.0 \
    && cp /files/lib/x86_64-linux-gnu/libkeyutils.so.1 /lib/x86_64-linux-gnu/libkeyutils.so.1 \
    && cp /files/usr/lib/x86_64-linux-gnu/liblber-2.4.so.2 /usr/lib/x86_64-linux-gnu/liblber-2.4.so.2 \
    && cp /files/usr/lib/x86_64-linux-gnu/libsasl2.so.2 /usr/lib/x86_64-linux-gnu/libsasl2.so.2 \
    \
    `#wireguard(boringtun)` \
    && cp /files/usr/bin/wg /usr/bin/wg \
    && cp /files/usr/bin/wg-quick /usr/bin/wg-quick \
    && cp /files/usr/bin/boringtun /usr/bin/boringtun \
    && cp /files/etc/wireguard/wg1.conf /etc/wireguard/wg1.conf \
    && cp /files/usr/bin/ip /usr/bin/ip \
    \
    `#wireguard(boringtun) depends` \
    && cp /files/lib/x86_64-linux-gnu/libmnl.so.0 /lib/x86_64-linux-gnu/libmnl.so.0 \
    && cp /files/usr/lib/x86_64-linux-gnu/libelf.so.1 /usr/lib/x86_64-linux-gnu/libelf.so.1 \
    && cp /files/lib/x86_64-linux-gnu/libcap.so.2 /lib/x86_64-linux-gnu/libcap.so.2 \
    \
    `#cockroachdb` \
    && tar xvzf /files/usr/bin/cockroach.tgz --strip-components 1 -C /usr/bin/ \
    \
    `#debug` \
    `#&& cp /files/usr/bin/strace /usr/bin/strace` \
    `#&& cp /files/usr/lib/x86_64-linux-gnu/libunwind-ptrace.so.0 /usr/lib/x86_64-linux-gnu/libunwind-ptrace.so.0` \
    `#&& cp /files/usr/lib/x86_64-linux-gnu/libunwind-x86_64.so.8 /usr/lib/x86_64-linux-gnu/libunwind-x86_64.so.8` \
    `#&& cp /files/usr/lib/x86_64-linux-gnu/libunwind.so.8 /usr/lib/x86_64-linux-gnu/libunwind.so.8` \
    `#&& cp /files/usr/bin/ping /usr/bin/ping` \
    \
    `#boot` \
    && cp /files/etc/rc.local /etc/rc.local

ENTRYPOINT /bin/bash -c "/etc/rc.local;/bin/bash"
