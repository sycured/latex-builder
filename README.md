# latex-builder

My OCI image used in CI/CD to build my LaTeX documents

## Packages installed

- [biber](https://github.com/plk/biber)
- [blacktex](https://github.com/nschloe/blacktex)
- [chktex](http://www.nongnu.org/chktex/)
- [cmake](https://cmake.org/)
- [ghostscript](https://www.ghostscript.com/)
- [ninja](https://github.com/ninja-build/ninja)
- [pdfcompressor](https://github.com/sycured/pdfcompressor)
- [rclone](https://github.com/rclone/rclone)
- [texlive](https://www.tug.org/texlive/)

## How to use it

### CLI

```shell
docker run --rm -v /Volumes/NAS/git_repositories/cv:/shared -v /tmp:/tmp -w /shared --entrypoint /shared/run.sh ghcr.io/sycured/latex-builder
```

### GitHub Actions

This is the workflow used for my private repository about my resume.

```yaml
name: ci
on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: [self-hosted, Linux, oraclecloud]
    container:
      image: ghcr.io/sycured/latex-builder:latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Install rclone config file
        env:
          rconf: ${{ secrets.RCLONE_CONF }}
        run: |
          echo "$rconf" | base64 -d > /rclone.conf
      - name: Build
        run: ./run.sh
      - name: Send pdf to objstore
        env:
          objstore: ${{ secrets.S3 }}
        run: "rclone --config /rclone.conf copy /tmp/build_cv/cv-en.pdf $objstore:"
```

This is `run.sh`:
```shell
#!/bin/bash

BD="/tmp/build_cv"
CD=$(pwd)
rm -rf "$BD"
mkdir "$BD" && cd "$BD" && cmake -G Ninja "$CD" && ninja &&
    pdfcompressor -o cv-en.pdf -i english.pdf
```
