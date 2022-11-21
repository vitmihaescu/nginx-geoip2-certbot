ARG ALPINE_VERSION=3.16
ARG NGINX_VERSION=1.23.2

FROM alpine:$ALPINE_VERSION as build
LABEL org.opencontainers.image.authors="Vit Mihaescu <vit.mihaescu@gmail.com>"
ARG NGINX_VERSION=1.23.2

# Install build tools and libraries
RUN apk add --no-cache --virtual \
    .build-deps \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre2-dev \
    zlib-dev \
    linux-headers \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    libmaxminddb-dev \
    perl-dev \
    libedit-dev \
    bash \
    alpine-sdk \
    findutils \
    git \
    && apk upgrade --available

# Build ngx_http_geoip2_module module
RUN cd /opt \
    && git clone https://github.com/leev/ngx_http_geoip2_module.git \
    && wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
    && tar zxvf nginx-$NGINX_VERSION.tar.gz \
    && cd nginx-$NGINX_VERSION \
    && ./configure --with-compat --add-dynamic-module=/opt/ngx_http_geoip2_module \
    && make modules \
    && cp /opt/nginx-$NGINX_VERSION/objs/ngx_http_geoip2_module.so /opt


FROM nginx:${NGINX_VERSION}-alpine as publish
LABEL org.opencontainers.image.authors="Vit Mihaescu <vit.mihaescu@gmail.com>"
VOLUME [ "/etc/nginx"]
VOLUME [ "/etc/letsencrypt/live"]
VOLUME [ "/usr/share/GeoIP" ]
EXPOSE 443


# Remove default entrypoint script
RUN rm -rf /docker-entrypoint.sh /docker-entrypoint.d

# Install prerequisites
RUN apk upgrade --available
RUN apk add --no-cache tini openrc busybox-initscripts libmaxminddb

# Copy ngx_http_geoip2_module
COPY --from=build /opt/ngx_http_geoip2_module.so /usr/lib/nginx/modules
RUN chmod -R 644 /usr/lib/nginx/modules/ngx_http_geoip2_module.so

# Install geoipupdate
RUN cd /opt \
    && wget https://github.com/maxmind/geoipupdate/releases/download/v4.10.0/geoipupdate_4.10.0_linux_amd64.tar.gz \
    && tar zxvf geoipupdate_4.10.0_linux_amd64.tar.gz \
    && cp ./geoipupdate_4.10.0_linux_amd64/geoipupdate /usr/bin/geoipupdate \
    && rm * -rf

# Install Certbot
RUN apk add --no-cache python3 \
    && curl -L 'https://bootstrap.pypa.io/get-pip.py' | python3 \
    && pip3 install -U cffi certbot \
    &&  pip3 uninstall pip -y \
    && rm -rf /root/.cache

# Copy nginx configuration and default content
RUN rm -rf /etc/nginx/* && ln -s /usr/lib/nginx/modules /etc/nginx/modules
COPY nginx/config/ /etc/nginx/
COPY nginx/content/ /usr/share/nginx/

# Periodic tasks
COPY scripts/ /etc/periodic/daily/
RUN chmod a+x /etc/periodic/daily/*

# Startup script
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

CMD crond && nginx -g "daemon off;"
