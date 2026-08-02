# Get base system
FROM debian:bookworm

# prevent issues from installs asking for stuff like timezones
ENV DEBIAN_FRONTEND=noninteractive

# get updates install them and then pulling nginx and clean the cache of apt
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY website /var/www/resume

EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]
