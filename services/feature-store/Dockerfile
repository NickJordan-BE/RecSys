FROM golangci/golangci-lint:v2.11.4-alpine AS linter

WORKDIR /app

COPY ./services/feature-store/go.mod ./services/feature-store/go.sum ./services/feature-store/.golangci.yml /app/

COPY ./services/feature-store/server ./server

RUN golangci-lint run ./server

FROM golang:1.26.1-alpine AS builder

COPY --from=linter /etc/passwd /dev/null

WORKDIR /app

RUN apk add --no-cache protobuf

RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.33 \
    && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3

ENV PATH="$PATH:$(go env GOPATH)/bin"

COPY ./services/feature-store/go.mod ./services/feature-store/go.sum /app/

RUN go mod download

COPY ./api/proto ./api/proto

RUN mkdir -p gen/go

RUN protoc -I ./api/proto \
    --go_out=gen/go --go_opt=paths=source_relative \
    --go-grpc_out=gen/go --go-grpc_opt=paths=source_relative \
    ./api/proto/*.proto

COPY ./services/feature-store/server /app/src

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/server /app/src

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/server .

CMD [ "./server" ]

ENTRYPOINT [ "./server" ]