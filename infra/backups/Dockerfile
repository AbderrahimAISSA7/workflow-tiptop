FROM alpine:3.20

RUN apk add --no-cache restic ca-certificates tzdata bash curl postgresql-client

RUN curl -fsSLo /usr/local/bin/supercronic https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64 && \
    chmod +x /usr/local/bin/supercronic

WORKDIR /app

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
