FROM alpine:3.20 AS librespot-builder
WORKDIR /app

ARG LIBRESPOT_VERSION=0.4.2

RUN apk add cargo curl git alsa-lib-dev

RUN git clone -b dev "https://github.com/librespot-org/librespot/"

WORKDIR /app/librespot

ENV CARGO_HOME=/app/cargo
# ENV RUSTFLAGS="-C target-feature=-crt-static"

RUN cargo build \
  --release \
  --verbose

FROM alpine:3.20 AS run

WORKDIR /app

# RUN apk add librespot@testing
RUN apk add alsa-lib libgcc

COPY --from=librespot-builder /app/librespot/target/release/librespot /usr/bin/librespot
COPY ./entrypoint.sh /app/entrypoint.sh
CMD [ "/app/entrypoint.sh" ]
