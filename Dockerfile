FROM rustlang/rust:nightly as builder
RUN rustup target add x86_64-unknown-linux-musl && \
    rustup component add rust-src --toolchain nightly-x86_64-unknown-linux-gnu
RUN apt update && apt install -y musl-tools musl-dev
RUN update-ca-certificates
WORKDIR /app
COPY . .
RUN cargo +nightly build -Z build-std=std,panic_abort -Z build-std-features=panic_immediate_abort --target=x86_64-unknown-linux-musl --release && \
    mv /app/target/x86_64-unknown-linux-musl/release/healthcheck  /app/healthcheck
RUN strip /app/healthcheck && \
    upx --lzma --best /app/healthcheck

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /app/healthcheck /healthcheck
USER 1000:1000
ENTRYPOINT ["/healthcheck"]