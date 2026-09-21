# ---------- Stage 1: compile the Yew (WebAssembly) frontend with Trunk ----------
FROM rust:1-slim-bookworm AS builder
RUN apt-get update && apt-get install -y pkg-config libssl-dev ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*
RUN rustup target add wasm32-unknown-unknown
RUN cargo install trunk --locked

WORKDIR /app
COPY . .
WORKDIR /app/frontend
RUN cargo update -p time@0.3 && trunk build --release

# ---------- Stage 2: serve the built files with Nginx ----------
FROM nginx:1.27-alpine
COPY --from=builder /app/frontend/dist /usr/share/nginx/html
EXPOSE 80
