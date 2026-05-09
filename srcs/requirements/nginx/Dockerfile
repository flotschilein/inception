# Get base system 
FROM debian:bookworm

# prevent issues from installs asking for stuff like timzones
ENV DEBIAN_FRONTEND=noninteractive

# get updates install them and then pulling mariadb and end clean the cache of apt 
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=DE/ST=BW/L=Heilbronn/O=42/OU=Inception/CN=${DOMAIN_NAME}"

COPY tools/script.sh /script.sh
COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /script.sh

EXPOSE 443