FROM golang:1.18-alpine AS base
WORKDIR /app

ENV GO11MODULE="on"
ENV GOOS="linux"
ENV CGO_ENABLED=0

RUN apk update \
    && apk add --no-cache \
    ca-certificates \
    curl \
    tzdata \
    git \
    && update-ca-certificates

FROM base AS dev
WORKDIR /app

RUN go get -u github.com/cosmtrek/air && go install github.com/go-delve/delve/cmd/dlv@latest
EXPOSE 5100
EXPOSE 2345

ENTRYPOINT ["air"]

FROM base AS builder
WORKDIR /app

COPY . /app
RUN go mod download \
    && go mod verify

RUN go build -o todo -a .

FROM alpine:latest AS prod

COPY --from=builder /app/todo /usr/local/bin/todo
EXPOSE 5100

ENTRYPOINT [ "/usr/local/bin/todo" ]