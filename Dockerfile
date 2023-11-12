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
    cargo install xargo && \
    rustup component add rust-src \
WORKDIR /app
COPY . .
RUN xargo build --release --target=x86_64-unknown-linux-gnu && \
    mv /app/target/x86_64-unknown-linux-gnu/release/healthcheck  /app/healthcheck
RUN strip /app/healthcheck && \
    upx --lzma --best /app/healthcheck

FROM gcr.io/distroless/static-debian12:noroot
COPY --from=builder /app/healthcheck /healthcheck
USER 1000:1000
ENTRYPOINT ["/healthcheck"]