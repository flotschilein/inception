# Get base system
FROM debian:bookworm

# prevent issues from installs asking for stuff like timezones
ENV DEBIAN_FRONTEND=noninteractive

# get updates install them and then pulling php and adminer and clean the cache of apt
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y php-cli php-mysql curl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer

# adminer is a single PHP file; it is served at /var/www/adminer/index.php so
# that the /adminer/ proxy path matches the container's document root
RUN curl -L -o /var/www/adminer/index.php \
    https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 8080

ENTRYPOINT ["/script.sh"]
