#!/bin/bash
set -x
mkimg=$(buildah from alpine)
buildah config --author='sycured' "$mkimg"
buildah config --label Name='latex-builder' "$mkimg"
buildah run "$mkimg" -- apk update
buildah run "$mkimg" -- apk upgrade
buildah run "$mkimg" -- apk add bash biber cmake ghostscript ninja py3-pip texlive texmf-dist-latexextra texmf-dist-fontsextra
buildah run "$mkimg" -- pip install --no-cache-dir blacktex
buildah run "$mkimg" -- mkdir /shared
buildah config --workingdir='/shared' "$mkimg"
buildah config --entrypoint='/shared/run.sh' "$mkimg"
mntimg=$(buildah mount "$mkimg")
rm -rf "$mntimg"/var/cache/apk/*
git clone https://gitlab.kitware.com/kmorel/UseLATEX.git
mv UseLATEX/UseLATEX.cmake "$mntimg"/usr/share/cmake/Modules/
git clone https://github.com/sycured/pdfcompressor.git
mv pdfcompressor/pdfcompressor "$mntimg"/usr/local/bin/
chmod 555 "$mntimg"/usr/local/bin/pdfcompressor
buildah unmount "$mkimg"
buildah commit --squash "$mkimg" "latex-builder"
buildah rm "$mkimg"
