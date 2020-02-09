#!/bin/bash
set -x
mkimg=$(buildah from archlinux)
buildah config --author='sycured' $mkimg
buildah config --label Name='latex-builder' $mkimg
buildah run "$mkimg" -- pacman -Syyu --noconfirm
buildah run "$mkimg" -- pacman -S --noconfirm biber cmake ghostscript grep ninja tar texlive-latexextra texlive-fontsextra
buildah run "$mkimg" -- pacman -Scc --noconfirm
buildah run "$mkimg" -- ln -s /usr/bin/vendor_perl/biber /usr/bin/biber
mntimg=$(buildah mount $mkimg)
rm -rf $mntimg/var/cache/pacman/pkg/*
git clone https://gitlab.kitware.com/kmorel/UseLATEX.git
mv UseLATEX/UseLATEX.cmake $mntimg/usr/share/cmake-*/Modules/
git clone https://github.com/sycured/pdfcompressor.git
mv pdfcompressor/pdfcompressor $mntimg/usr/local/bin/
chmod 555 $mntimg/usr/local/bin/pdfcompressor
buildah unmount $mkimg
buildah commit --squash "$mkimg" "latex-builder"
buildah rm "$mkimg"
