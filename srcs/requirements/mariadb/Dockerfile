# Get base system 
FROM debian:bookworm

# prevent issues from installs asking for stuff like timzones
ENV DEBIAN_FRONTEND=noninteractive

# get updates install them and then pulling mariadb and end clean the cache of apt 
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/mysql && \
    rm -rf /var/lib/apt/lists/*

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/my.cnf 
COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 3306

ENTRYPOINT ["/script.sh"]