FROM golang:1.24-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/gateway

FROM alpine:3.19 AS runner
RUN apk add --no-cache ca-certificates && adduser -D -H appuser
WORKDIR /app
COPY --from=builder /app/main .
COPY --from=builder /app/configs ./configs
USER appuser
EXPOSE 9000
ENTRYPOINT ["./main"]

