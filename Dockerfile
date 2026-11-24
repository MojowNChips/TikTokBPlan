# n8n + the command-line tools the TikTok workflows call from Execute Command nodes:
# ffmpeg, python3 (+requests), yt-dlp, whisper-cli (whisper.cpp) and the AWS CLI (for R2).
#
# The official n8n image is "Docker Hardened Images (Alpine)" and ships without apk,
# so a static apk is borrowed from stock Alpine of the same release.
# Keep ALPINE in step with the n8n image (docker run --rm n8nio/n8n cat /etc/os-release).
ARG ALPINE=3.24

# ---- whisper.cpp (CPU build, no PyTorch) -------------------------------------
FROM alpine:${ALPINE} AS whisper-build
RUN apk add --no-cache git cmake make g++ linux-headers
RUN git clone --depth 1 https://github.com/ggml-org/whisper.cpp /src
WORKDIR /src
RUN cmake -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DGGML_NATIVE=OFF \
      -DWHISPER_BUILD_TESTS=OFF -DWHISPER_BUILD_EXAMPLES=ON \
 && cmake --build build -j"$(nproc)" --target whisper-cli

# ---- static apk ----------------------------------------------------------------
FROM alpine:${ALPINE} AS apk
RUN apk add --no-cache apk-tools-static

# ---- final image ---------------------------------------------------------------
FROM n8nio/n8n:latest
USER root
COPY --from=apk /sbin/apk.static /sbin/apk
COPY --from=apk /etc/apk /etc/apk
COPY --from=apk /lib/apk /lib/apk
RUN apk add --no-cache --no-scripts \
      ffmpeg python3 py3-pip py3-requests aws-cli libgomp fontconfig font-dejavu \
 && pip3 install --no-cache-dir --break-system-packages -U yt-dlp \
 && mkdir -p /temp /output /models && chown node:node /temp /output
COPY --from=whisper-build /src/build/bin/whisper-cli /usr/local/bin/whisper-cli
USER node
