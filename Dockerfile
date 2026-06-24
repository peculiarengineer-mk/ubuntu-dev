# syntax=docker/dockerfile:1
#
# peculiarengineer/ubuntu-dev — a lean Ubuntu 26.04 LTS devcontainer base.
#
# Standard dev toolset (build-essential, git, ripgrep, fd, jq, zsh, ...) plus a
# passwordless-sudo non-root 'vscode' user, ready to use directly as a VS Code
# Dev Container / Codespaces base image. Multi-arch (amd64/arm64).

FROM ubuntu:26.04

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

LABEL org.opencontainers.image.title="ubuntu-dev" \
      org.opencontainers.image.description="Ubuntu 26.04 LTS devcontainer base with a standard dev toolset" \
      org.opencontainers.image.source="https://github.com/peculiarengineer-mk/ubuntu-dev" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.authors="Minor Keith <keithminork@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=Etc/UTC

# --- Standard dev toolset ---------------------------------------------------
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates curl wget gnupg \
        git openssh-client \
        build-essential pkg-config \
        sudo locales tzdata tini \
        less nano vim \
        ripgrep fd-find jq \
        bash-completion zsh \
        unzip zip tar gzip xz-utils \
        procps htop tree man-db lsb-release; \
    # fd ships as 'fdfind' on Debian/Ubuntu — add the conventional 'fd' alias.
    ln -sf "$(command -v fdfind)" /usr/local/bin/fd; \
    # Generate the UTF-8 locale we set above.
    sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen; \
    locale-gen; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# --- Non-root user with passwordless sudo -----------------------------------
# Ubuntu 24.04+ base images ship a default 'ubuntu' user at UID 1000; drop it so
# we can own UID 1000 with our predictable 'vscode' user.
RUN set -eux; \
    if id -u ubuntu >/dev/null 2>&1; then userdel -r ubuntu 2>/dev/null || true; fi; \
    if getent group "${USER_GID}" >/dev/null 2>&1; then \
        existing_group="$(getent group "${USER_GID}" | cut -d: -f1)"; \
        groupmod -n "${USERNAME}" "${existing_group}"; \
    else \
        groupadd --gid "${USER_GID}" "${USERNAME}"; \
    fi; \
    useradd --uid "${USER_UID}" --gid "${USER_GID}" -m -s /bin/bash "${USERNAME}"; \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}"; \
    chmod 0440 "/etc/sudoers.d/${USERNAME}"

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# tini as PID 1 for correct signal handling / zombie reaping.
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bash"]
