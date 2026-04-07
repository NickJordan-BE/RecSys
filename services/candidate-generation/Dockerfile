FROM golang:1.26.1-alpine AS base

WORKDIR /app

COPY ./go.mod ./go.sum /app/

RUN go mod download

FROM golangci/golangci-lint:v2.11.4-alpine AS linter

WORKDIR /app

COPY ./go.mod ./go.sum .golangci.yml /app/

COPY ./server ./server

RUN golangci-lint run ./server

FROM base AS builder

WORKDIR /app

COPY --from=linter /etc/passwd /dev/null

COPY ./server /app/server

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o server /app/server

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/server .

CMD [ "./server" ]

ENTRYPOINT [ "./server" ]