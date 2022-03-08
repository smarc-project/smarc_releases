#!/bin/bash

# Example usage: ./release_repos.sh focal noetic release_repos.yaml
# Example usage: ./release_repos.sh bionic melodic release_repos.yaml

which python3
python3 -c "import setuptools; print(setuptools.__version__)"
ls
mkdir bloom-release-debs
while read repo_line; do
  repo=$(echo $repo_line | cut -c3-)
  echo "Doing ${repo}"
  ls $repo
  pkgs_file="${repo}/${3}"
  has_config=$(test -f "$pkgs_file" && echo true || echo false)
  if $has_config; then
    echo "Found ${pkgs_file}"
    pkgs=()
    while read line; do
      echo $line
      pkgs+=($(echo $line | cut -c3-))
    done < $pkgs_file
    cd $repo
  else
    echo "Did not find ${pkgs_file}"
    pkgs=("${repo}")
  fi
  echo ${pkgs[*]}
  for pkg in ${pkgs[*]}; do
    echo "Doing ${pkg}"
    cd $pkg
    ls
    rosdep install --from-path . --ignore-src --rosdistro $2 -y
    bloom-generate rosdebian --os-name ubuntu --os-version $1 --ros-distro $2
    fakeroot debian/rules binary
    cd ..
    sudo dpkg -i ros-${2}-*.deb
    if $has_config; then
      mv ros-${2}-*.deb ../bloom-release-debs
    else
      mv ros-${2}-*.deb bloom-release-debs
    fi
  done
  if $has_config; then
    cd ..
  fi
done < release_repos.yaml
zip -j bloom-${2}-release-deb.zip bloom-release-debs/*
ls
