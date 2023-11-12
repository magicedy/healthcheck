FROM rustlang/rust:nightly as builder
RUN apt-get update && \
    apt-get install -q -y --no-install-recommends \
    nasm \
    binutils \
    grub-common \
    xorriso \
    grub-pc-bin \
    upx && \
    apt-get autoremove -q -y && \
    apt-get clean -q -y && \
    rm -rf /var/lib/apt/lists/* && \
RUN rustup component add rust-src
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