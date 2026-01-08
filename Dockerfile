# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build arguments
ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG VERSION=v1.0.0

# Build the binary
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build \
    -ldflags "-X main.AppVersion=${VERSION}" \
    -o bot ./cmd/bot

# Final stage
FROM scratch

WORKDIR /

# Copy the binary from builder
COPY --from=builder /app/bot /bot

# Copy CA certificates for HTTPS
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["/bot"]

