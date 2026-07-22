FROM alpine:3.20

RUN apk update && apk upgrade && apk add --no-cache redis

COPY conf/redis.conf /etc/redis.conf
COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 6379

ENTRYPOINT ["/script.sh"]
