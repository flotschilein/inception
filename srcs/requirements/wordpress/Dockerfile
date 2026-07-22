# Get base system 
FROM debian:bookworm

# prevent issues from installs asking for stuff like timzones
ENV DEBIAN_FRONTEND=noninteractive

# get updates install them and then pulling mariadb and end clean the cache of apt 
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y php-fpm php-mysql php-mysqli curl wget tar && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress/* . && \
    rm -rf wordpress latest.tar.gz

RUN sed -i 's|listen = .*|listen = 9000|' /etc/php/*/fpm/pool.d/www.conf

RUN chown -R www-data:www-data /var/www/html

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 9000

ENTRYPOINT ["/script.sh"]