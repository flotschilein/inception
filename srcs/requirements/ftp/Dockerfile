# Get base system
FROM debian:bookworm

# prevent issues from installs asking for stuff like timezones
ENV DEBIAN_FRONTEND=noninteractive

# get updates install them and then pulling vsftpd and clean the cache of apt
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y vsftpd && \
    rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 21 21000-21099

ENTRYPOINT ["/script.sh"]
