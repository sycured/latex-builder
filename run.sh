#!/bin/bash
set -x

mkbuild=$(buildah from alpine)
buildah run "$mkbuild" -- apk update
buildah run "$mkbuild" -- apk upgrade
buildah run "$mkbuild" -- apk add autoconf automake gcc git libc-dev libtool make
buildah run "$mkbuild" -- git clone https://git.savannah.gnu.org/git/chktex.git
buildah run "$mkbuild" -- bash -c "mkdir -p /usr/local/etc && cd chktex/chktex && sh autogen.sh --prefix=/usr/bin && ./configure && make && install chktex /usr/bin && install chktexrc /usr/local/etc"
mntbuild=$(buildah mount "$mkbuild")

mkimg=$(buildah from python:alpine)
buildah config --author='sycured' "$mkimg"
buildah config --label Name='latex-builder' "$mkimg"
buildah run "$mkimg" -- apk update
buildah run "$mkimg" -- apk upgrade
buildah run "$mkimg" -- apk add bash biber cmake coreutils ghostscript ninja py3-pip rclone texlive texlive-dvi texmf-dist-latexextra texmf-dist-fontsextra
buildah run "$mkimg" -- pip install --no-cache-dir blacktex
buildah run "$mkimg" -- mkdir -p /usr/local/etc
mntimg=$(buildah mount "$mkimg")
rm -rf "$mntimg"/var/cache/apk/*
cp "$mntbuild"/usr/bin/chktex "$mntimg"/usr/bin/chktex
cp "$mntbuild"/usr/local/etc/chktexrc "$mntimg"/usr/local/etc/chktexrc
chmod 555 "$mntimg"/usr/bin/chktex
buildah unmount "$mkbuild"
buildah rm "$mkbuild"
git clone https://gitlab.kitware.com/kmorel/UseLATEX.git
mv UseLATEX/UseLATEX.cmake "$mntimg"/usr/share/cmake/Modules/
git clone https://github.com/sycured/pdfcompressor.git
mv pdfcompressor/pdfcompressor "$mntimg"/usr/local/bin/
chmod 555 "$mntimg"/usr/local/bin/pdfcompressor
buildah unmount "$mkimg"
buildah commit --squash "$mkimg" "latex-builder"
buildah rm "$mkimg"
