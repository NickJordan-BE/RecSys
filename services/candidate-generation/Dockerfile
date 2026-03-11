FROM golang:1.25.5-alpine AS builder

WORKDIR /app

COPY ./go.mod ./go.sum /app/

RUN go mod download

COPY ./server /app/server

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o server /app/server

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/server .

CMD ["./server"]