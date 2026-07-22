# Get base system 
FROM debian:bookworm

# prevent issues from installs asking for stuff like timzones
ENV DEBIAN_FRONTEND=noninteractive

# get updates install them and then pulling mariadb and end clean the cache of apt 
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

COPY tools/script.sh /script.sh
COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /script.sh

EXPOSE 443

ENTRYPOINT ["/script.sh"]