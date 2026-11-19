FROM golang:1.27 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /academe-api ./cmd/academe-api

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /academe-api /academe-api
EXPOSE 8080
ENTRYPOINT ["/academe-api"]
