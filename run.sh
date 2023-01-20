#!/bin/bash
set -x

mkimg=$(buildah from registry.opensuse.org/opensuse/tumbleweed:latest)
buildah config --author="sycured" --label Name="latex-builder" --label org.opencontainers.image.source="https://github.com/sycured/latex-builder" "${mkimg}"
buildah run "${mkimg}" -- bash -c 'echo "download.min_download_speed=10000000" >> /etc/zypp/zypp.conf'
buildah run "${mkimg}" -- zypper update -y
buildah run "${mkimg}" -- zypper install -y cmake ghostscript git gzip perl-Image-ExifTool poppler-tools qpdf rclone samurai shadow tar texlive texlive-chktex texlive-luatex texlive-collection-latexextra texlive-collection-fontsextra
buildah run "${mkimg}" -- useradd -ms /bin/bash latex
buildah run "${mkimg}" -- mkdir -p /home/latex/.config/rclone
buildah run "${mkimg}" -- chown -R latex:latex /home/latex/.config
mntimg=$(buildah mount "${mkimg}")
rm -rf "${mntimg}"/var/lib/rpm/*
rm -rf "${mntimg}"/var/cache/zypp/*
git clone https://gitlab.kitware.com/kmorel/UseLATEX.git
mv UseLATEX/UseLATEX.cmake "${mntimg}"/usr/share/cmake/Modules/
mv entrypoint.sh "${mntimg}"/
buildah config --user=latex --workingdir="/home/latex" "${mkimg}"
buildah config --entrypoint "/entrypoint.sh" "${mkimg}"
buildah unmount "${mkimg}"
buildah commit --squash "${mkimg}" "latex-builder"
buildah rm "${mkimg}"
