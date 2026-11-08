# Development - có Go compiler + Air để hot reload
FROM golang:1.24-alpine

RUN apk add --no-cache build-base

# Cài Air để tự động restart khi code thay đổi
RUN go install github.com/air-verse/air@v1.61.0

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

EXPOSE 8080

# Dùng Air thay vì go run để có hot reload
CMD ["air"]