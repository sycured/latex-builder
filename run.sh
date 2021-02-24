#!/bin/bash
set -x

mkimg=$(buildah from fedora:rawhide)
buildah config --author='sycured' "$mkimg"
buildah config --label Name='latex-builder' "$mkimg"
buildah run "$mkimg" -- dnf upgrade -y
buildah run "$mkimg" -- dnf install -y biber cmake ghostscript ninja-build python3-pip rclone texlive texlive-chktex texlive-luatex texlive-collection-latexextra texlive-collection-fontsextra
buildah run "$mkimg" -- pip install --no-cache-dir blacktex
mntimg=$(buildah mount "$mkimg")
rm -rf "$mntimg"/var/cache/dnf/*
git clone https://gitlab.kitware.com/kmorel/UseLATEX.git
mv UseLATEX/UseLATEX.cmake "$mntimg"/usr/share/cmake/Modules/
git clone https://github.com/sycured/pdfcompressor.git
mv pdfcompressor/pdfcompressor "$mntimg"/usr/local/bin/
chmod 555 "$mntimg"/usr/local/bin/pdfcompressor
buildah unmount "$mkimg"
buildah commit --squash "$mkimg" "latex-builder"
buildah rm "$mkimg"
