# Get base system 
FROM debian:bookworm

# prevent issues from installs asking for stuff like timzones
ENV DEBIAN_FRONTEND=noninteractive

# get updates install them and then pulling mariadb and end clean the cache of apt 
RUN apt-get update && \
    apt-get upgrade -y && 

COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 9000

ENTRYPOINT ["/script.sh"]