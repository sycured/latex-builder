#!/bin/bash
set -x

mkimg=$(buildah from fedora-minimal:rawhide)
buildah config --author="sycured" --label Name="latex-builder" --label org.opencontainers.image.source="https://github.com/sycured/latex-builder" "$mkimg"
buildah run "$mkimg" -- microdnf upgrade -y
buildah run "$mkimg" -- microdnf --nodocs --setopt=install_weak_deps=0 --best install -y cmake ghostscript gzip ninja-build rclone tar texlive texlive-chktex texlive-luatex texlive-collection-latexextra texlive-collection-fontsextra
buildah run "$mkimg" -- useradd -ms /bin/bash latex
mntimg=$(buildah mount "$mkimg")
rm -rf "$mntimg"/var/cache/dnf/*
git clone https://gitlab.kitware.com/kmorel/UseLATEX.git
mv UseLATEX/UseLATEX.cmake "$mntimg"/usr/share/cmake/Modules/
buildah config --user=latex --workingdir='/home/latex' "$mkimg"
buildah unmount "$mkimg"
buildah commit --squash "$mkimg" "latex-builder"
buildah rm "$mkimg"
