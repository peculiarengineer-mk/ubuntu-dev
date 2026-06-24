# ubuntu-dev

A lean **Ubuntu 26.04 LTS** devcontainer base image with a standard dev toolset
and a passwordless-sudo `vscode` user. Multi-arch (`amd64` / `arm64`).

```bash
docker pull peculiarengineer/ubuntu-dev:26.04
```

[![Docker Pulls](https://img.shields.io/docker/pulls/peculiarengineer/ubuntu-dev)](https://hub.docker.com/r/peculiarengineer/ubuntu-dev)
[![Image Size](https://img.shields.io/docker/image-size/peculiarengineer/ubuntu-dev/26.04)](https://hub.docker.com/r/peculiarengineer/ubuntu-dev/tags)

## What's inside

- **Base:** `ubuntu:26.04`
- **User:** non-root `vscode` (UID/GID 1000) with passwordless `sudo`
- **Init:** `tini` as PID 1 (clean signal handling)
- **Locale:** `en_US.UTF-8`
- **Tools:** `build-essential`, `pkg-config`, `git`, `curl`/`wget`, `ripgrep`
  (`rg`), `fd`, `jq`, `vim`/`nano`, `zsh`, `bash-completion`, `htop`, `tree`,
  `unzip`/`zip`, `openssh-client`, `man`, `lsb-release`

Anything language-specific (Node, Python, Go, Docker-in-Docker, gh) is left to
**Dev Container Features** so the base stays small — see `.devcontainer/devcontainer.json`.

## Use as a devcontainer

Open the folder in VS Code → **Reopen in Container**. The included
`.devcontainer/devcontainer.json` builds from the Dockerfile. To consume the
published image instead, replace the `build` block with:

```jsonc
"image": "peculiarengineer/ubuntu-dev:26.04"
```

## Use standalone

```bash
# Build
docker build -t peculiarengineer/ubuntu-dev:26.04 .

# Interactive shell as the non-root user
docker run --rm -it peculiarengineer/ubuntu-dev:26.04

# Mount your project and work in it
docker run --rm -it -v "$PWD":/work -w /work peculiarengineer/ubuntu-dev:26.04
```

## Multi-arch build

```bash
docker buildx build --platform linux/amd64,linux/arm64 \
  -t peculiarengineer/ubuntu-dev:26.04 --push .
```

## Staying up to date

The published image is rebuilt automatically by
[`.github/workflows/build.yml`](./.github/workflows/build.yml):

- **Weekly** (Mondays 06:00 UTC) and on any change to the `Dockerfile`.
- Each run rebuilds multi-arch (`amd64`/`arm64`) with `--pull`, so it re-fetches
  `ubuntu:26.04` and the latest apt packages — picking up upstream base and
  security updates without a version bump.
- Pushes tags `:26.04` and `:latest`.

Requires two repository secrets: `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`
(a Docker Hub [access token](https://hub.docker.com/settings/security) with
read/write scope). You can also trigger a rebuild manually from the **Actions**
tab (**Run workflow**).

## Customizing

- **User:** override at build time — `--build-arg USERNAME=dev --build-arg USER_UID=1001`
- **Extra tools:** prefer `features` in `devcontainer.json` over editing the Dockerfile.

## License

MIT — see [LICENSE](./LICENSE).
