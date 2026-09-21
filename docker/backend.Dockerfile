# ---------- Stage 1: build the Rust backend ----------
FROM rust:1-slim-bookworm AS builder
WORKDIR /app
COPY . .
RUN cargo update -p time@0.3 && cargo build --release -p backend

# ---------- Stage 2: small runtime image ----------
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
RUN adduser --system --no-create-home --group appuser
COPY --from=builder /app/target/release/backend /usr/local/bin/backend

# Rocket listens on 127.0.0.1 by default, which is unreachable from other
# containers. These make it listen on all interfaces.
ENV ROCKET_ADDRESS=0.0.0.0
ENV ROCKET_PORT=8000

USER appuser
EXPOSE 8000
CMD ["backend"]
