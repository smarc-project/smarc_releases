#!/bin/bash

mkdir -p package_repo
cd package_repo
    
for distro in melodic noetic; do
    mkdir -p ${distro}
    curl -s https://api.github.com/repos/smarc-project/smarc_releases/releases/latest \
    | grep "bloom-${distro}-wasm-release-deb.zip" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -qi -

    unzip -o bloom-${distro}-wasm-release-deb.zip -d ${distro}/ #--out
    rm bloom-${distro}-wasm-release-deb.zip
done

mv melodic debian # for backwards compatibility

for distro in debian noetic; do
    dpkg-scanpackages ${distro} /dev/null | gzip -9c > ${distro}/Packages.gz
done

