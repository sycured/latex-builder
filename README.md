# latex-builder

My OCI image used in CI/CD to build my LaTeX documents

[![ci](https://github.com/sycured/latex-builder/actions/workflows/buildah.yml/badge.svg?branch=master)](https://github.com/sycured/latex-builder/actions/workflows/buildah.yml)

## Packages installed

- [chktex](http://www.nongnu.org/chktex/)
- [cmake](https://cmake.org/)
- [ghostscript](https://www.ghostscript.com/)
- [git](https://git-scm.com)
- [poppler](https://poppler.freedesktop.org)
- [rclone](https://github.com/rclone/rclone)
- [samurai](https://github.com/michaelforney/samurai)
- [texlive](https://www.tug.org/texlive/)
- [uselatex](https://gitlab.kitware.com/kmorel/UseLATEX)

## How to use it
### SHELL script
Example for `run.sh`:
```shell
#!/bin/bash

BD="/tmp/build_cv"
CD=$(pwd)
rm -rf "$BD"
mkdir "$BD" && cd "$BD" && cmake -G Ninja "$CD" && samu
```
### Basic usage
#### CLI

```shell
docker run --rm -v /Volumes/NAS/git_repositories/cv:/shared -v /tmp:/tmp -w /shared ghcr.io/sycured/latex-builder
```
#### Environment variables

| Name                  | Description                                               | Default       |
| --------------------- | --------------------------------------------------------- | :-----------: |
| GIT_BRANCH            | which branch/tag/commit to clone                          | main          |
| GIT_HOST              | git server                                                | github.com    |
| GIT_PRIVATE_KEY       | ssh private key (base64)                                  |               |
| GIT_REPO              | repository to clone (ex: _sycured/latex-builder_)         |               |
| GIT_TOKEN             | personal access token (plaintext)                         |               |
| GIT_USER              | git username needed when using GIT_TOKEN (ex: _sycured_)  |               |
| RCLONE_ACTION         | define which action rclone will run                       | copy          |
| RCLONE_CONFIG         | rclone configuration (plaintext)                          |               |
| RCLONE_CONFIG_B64     | rclone configuration (base64)                             |               |
| RCLONE_LOCAL_PATH     | rclone copy source (local path)                           |               |
| RCLONE_REMOTE_PATH    | rsync copy destination (remote path)                      |               |
| SCRIPT                | shell script to execute                                   | `./run.sh`    |
