#!/bin/bash
set -x

mkimg=$(buildah from fedora-minimal:rawhide)
buildah config --author="sycured" --label Name="latex-builder" --label org.opencontainers.image.source="https://github.com/sycured/latex-builder" "${mkimg}"
buildah run "${mkimg}" -- microdnf upgrade -y
buildah run "${mkimg}" -- microdnf --nodocs --setopt=install_weak_deps=0 --best install -y cmake ghostscript git gzip poppler-utils rclone samurai tar texlive texlive-chktex texlive-luatex texlive-collection-latexextra texlive-collection-fontsextra
buildah run "${mkimg}" -- microdnf remove microdnf libdnf -y
buildah run "${mkimg}" -- useradd -ms /bin/bash latex
buildah run "${mkimg}" -- mkdir -p /home/latex/.config/rclone
buildah run "${mkimg}" -- chown -R latex:latex /home/latex/.config
mntimg=$(buildah mount "${mkimg}")
rm -rf "${mntimg}"/var/lib/dnf/*
rm -rf "${mntimg}"/var/cache/yum/*
git clone https://gitlab.kitware.com/kmorel/UseLATEX.git
mv UseLATEX/UseLATEX.cmake "${mntimg}"/usr/share/cmake/Modules/
mv entrypoint.sh "${mntimg}"/
buildah config --user=latex --workingdir="/home/latex" "${mkimg}"
buildah config --entrypoint "/entrypoint.sh" "${mkimg}"
buildah unmount "${mkimg}"
buildah commit --squash "${mkimg}" "latex-builder"
buildah rm "${mkimg}"
