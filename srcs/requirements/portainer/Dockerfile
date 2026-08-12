# Get base system
FROM debian:bookworm

# prevent issues from installs asking for stuff like timezones
ENV DEBIAN_FRONTEND=noninteractive

# get updates install them and then pulling curl/ca-certificates and clean the cache of apt
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl ca-certificates tar && \
    rm -rf /var/lib/apt/lists/*

# download and extract the portainer CE binary
RUN curl -L -o /tmp/portainer.tar.gz \
    https://github.com/portainer/portainer/releases/download/v2.21.5/portainer-ce-2.21.5-linux-amd64.tar.gz && \
    tar xzf /tmp/portainer.tar.gz -C /opt && \
    rm /tmp/portainer.tar.gz

EXPOSE 9000

ENTRYPOINT ["/opt/portainer/portainer", "-p", ":9000"]