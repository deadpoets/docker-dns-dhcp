FROM ubuntu:latest AS add-apt-repositories

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg \
 && apt-key adv --fetch-keys http://www.webmin.com/jcameron-key.asc \
 && echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list

FROM ubuntu:latest

LABEL maintainer="chris@cxjxf.com"

ENV BIND_USER=bind \
    BIND_VERSION=9.16.6 \
    WEBMIN_VERSION=1.970 \
    DHCP_VERSION=4.4.1 \
    DHCP_USER=dhcpd \
    DHCP_INTERFACES=" " \
    DATA_DIR=/data

COPY --from=add-apt-repositories /etc/apt/trusted.gpg /etc/apt/trusted.gpg

COPY --from=add-apt-repositories /etc/apt/sources.list /etc/apt/sources.list

RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      bind9=1:${BIND_VERSION}* bind9-host=1:${BIND_VERSION}* dnsutils \
      webmin=${WEBMIN_VERSION}* isc-dhcp-server=${DHCP_VERSION} \
 && apt -q -y autoremove \
 && apt -q -y clean \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp 67/udp 68/udp 10000/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/named"]
