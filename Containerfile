FROM scratch AS ctx
COPY build_files /

FROM quay.io/fedora/fedora-silverblue:latest

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    dnf copr enable -y imput/helium && \
    dnf install -y helium-bin
    
RUN bootc container lint
