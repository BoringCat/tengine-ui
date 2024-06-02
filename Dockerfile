ARG NGINX_UI_VERSION=v2.0.0-beta.24
FROM uozi/nginx-ui:${NGINX_UI_VERSION} as nginx-ui-bin

FROM alpine as tengine-env
WORKDIR /etc/nginx-ui
ARG APK_MIRROR
ARG APK_MIRROR_HTTPS
RUN --mount=type=cache,target=/cache\
    set -xe;\
    [ ! -z "${APK_MIRROR}" -a "${APK_MIRROR}" != "dl-cdn.alpinelinux.org" ]\
 && sed -i "s/dl-cdn.alpinelinux.org/${APK_MIRROR}/g" /etc/apk/repositories ;\
 if [ "${APK_MIRROR_HTTPS}" = "true" ]; then\
    sed -e "s!http://!https://!g" -i /etc/apk/repositories;\
 elif [ "${APK_MIRROR_HTTPS}" = "false" ]; then\
    sed -e "s!https://!http://!g" -i /etc/apk/repositories;\
 fi\
 && apk add --update --cache-dir /cache/apk\
    libmaxminddb pcre openssl zlib libxslt gd geoip libedit perl lua yajl\
    logrotate tzdata\
 && addgroup nginx\
 && adduser -s /sbin/nologin -G nginx -D -H nginx

FROM tengine-env AS tengine-build-env
RUN --mount=type=cache,target=/cache\
    set -xe\
 && apk add --update --cache-dir /cache/apk --virtual .build-deps \
    gcc libc-dev make openssl-dev pcre-dev \
    zlib-dev linux-headers libxslt-dev gd-dev \
    geoip-dev libedit-dev perl-dev lua-dev yajl-dev mercurial \
    gnupg alpine-sdk findutils cmake libevent-dev

FROM tengine-build-env as tengine-builder
WORKDIR /usr/src/

ARG TENGINE_VERSION=3.1.0
ARG BROTLI_VERISON=1.0.0rc
ARG NGX_CACHE_PURGE_VERSION=2.5.3

COPY sources/ /usr/src/
COPY docker/logrotate /usr/src/

ARG BUILD_THREADS=1
ARG TARGER=/dst
ARG TENGINE_BUILDFLAG
RUN set -xe\
 && MAKEARG="-j${BUILD_THREADS:-1}"\
 && tar -zxC /usr/src -f /usr/src/tengine-${TENGINE_VERSION}.tar.gz\
 && if [ -f "/usr/src/ngx_brotli-${BROTLI_VERISON}.tar.gz" ]; then\
   tar -zxC /usr/src/tengine-${TENGINE_VERSION}/modules -f /usr/src/ngx_brotli-${BROTLI_VERISON}.tar.gz;\
   mv /usr/src/tengine-${TENGINE_VERSION}/modules/ngx_brotli-${BROTLI_VERISON} /usr/src/tengine-${TENGINE_VERSION}/modules/ngx_brotli;\
 fi\
 && if [ -f "/usr/src/ngx_cache_purge-${NGX_CACHE_PURGE_VERSION}.tar.gz" ]; then\
   tar -zxC /usr/src/tengine-${TENGINE_VERSION}/modules -f /usr/src/ngx_cache_purge-${NGX_CACHE_PURGE_VERSION}.tar.gz;\
   mv /usr/src/tengine-${TENGINE_VERSION}/modules/ngx_cache_purge-${NGX_CACHE_PURGE_VERSION} /usr/src/tengine-${TENGINE_VERSION}/modules/ngx_cache_purge;\
 fi\
 && cd /usr/src/tengine-${TENGINE_VERSION}\
 && ./configure --user=nginx --group=nginx\
 --prefix="/etc/nginx"\
 --sbin-path="/usr/local/sbin/nginx"\
 --error-log-path="/var/log/nginx/error.log"\
 --pid-path="/var/log/nginx/nginx.pid"\
 --lock-path="/var/log/nginx/nginx.lck"\
 --http-log-path="/var/log/nginx/access.log"\
 --http-client-body-temp-path="/var/cache/nginx/client_body_temp"\
 --http-proxy-temp-path="/var/cache/nginx/proxy_temp"\
 --http-fastcgi-temp-path="/var/cache/nginx/fastcgi_temp"\
 --http-uwsgi-temp-path="/var/cache/nginx/uwsgi_temp"\
 --http-scgi-temp-path="/var/cache/nginx/scgi_temp"\
 ${TENGINE_BUILDFLAG}\
 --add-module=modules/ngx_brotli\
 --add-module=modules/ngx_cache_purge\
 && make ${MAKEARG} && env DESTDIR=${TARGER} make install
RUN set -xe\
 && mkdir -p ${TARGER}/var/cache/nginx/client_body_temp\
    ${TARGER}/var/cache/nginx/proxy_temp\
    ${TARGER}/var/cache/nginx/fastcgi_temp\
    ${TARGER}/var/cache/nginx/uwsgi_temp\
    ${TARGER}/var/cache/nginx/scgi_temp\
    ${TARGER}/var/log/nginx\
    ${TARGER}/etc/logrotate.d\
    ${TARGER}/etc/nginx/conf/sites-available\
    ${TARGER}/etc/nginx/conf/sites-enabled\
    ${TARGER}/etc/nginx/conf/streams-available\
    ${TARGER}/etc/nginx/conf/streams-enabled\
    ${TARGER}/usr/local/etc\
 && touch ${TARGER}/var/log/nginx/error.log ${TARGER}/var/log/nginx/access.log\
 && cp -v /usr/src/logrotate /etc/logrotate.d/nginx\
 && cp -rv ${TARGER}/etc/nginx ${TARGER}/usr/local/etc/nginx
COPY docker/*.sh ${TARGER}/usr/local/bin/

FROM tengine-env
ARG TARGER=/dst
COPY --from=tengine-builder ${TARGER}/ /
COPY --from=nginx-ui-bin /usr/local/bin/nginx-ui /usr/local/bin/
VOLUME [ "/etc/nginx", "/var/log/nginx", "/app" ]
EXPOSE 80 443 9000
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD []