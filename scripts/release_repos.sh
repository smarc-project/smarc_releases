#!/bin/bash -e

# Example usage: ./release_repos.sh focal noetic release_repos.yaml
# Example usage: ./release_repos.sh bionic melodic release_repos.yaml

which python3
python3 -c "import setuptools; print(setuptools.__version__)"
ls
mkdir bloom-release-debs
while read repo_line; do
  repo=$(echo $repo_line | cut -c3-)
  # only melodic needs a newer self-hosted geographic_info
  if [ "$repo" == "geographic_info" ] && [ "$2" != "melodic" ]; then
    continue
  fi
  echo "--- Doing repo ${repo}"
  ls $repo
  if [ "$repo" != "geographic_info" ] && [ "$repo" != "cola2_msgs" ]; then
    cd $repo
    # do not push version bumps until we know everything builds
    catkin_prepare_release --bump patch -y --no-push
    cd ..
  fi
  pkgs_file="${repo}/release_packages.yaml"
  has_config=$(test -f "$pkgs_file" && echo true || echo false)
  if $has_config; then
    echo "--- Found release_packages.yaml: ${pkgs_file}"
    pkgs=()
    while read line; do
      echo $line
      pkgs+=($(echo $line | cut -c3-))
    done < $pkgs_file
    cd $repo
  else
    echo "--- Did not find release_package.yaml: ${pkgs_file}"
    pkgs=("${repo}")
  fi
  echo ${pkgs[*]}
  for pkg in ${pkgs[*]}; do
    echo "--- Doing package ${pkg}"
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
done < $3
zip -j bloom-${2}-release-deb.zip bloom-release-debs/*
rm -rf bloom-release-debs
ls
# push version bumps, only on noetic!
if [ "$2" == "noetic" ]; then
  while read repo_line; do
    repo=$(echo $repo_line | cut -c3-)
    if [ "$repo" != "geographic_info" ] && [ "$repo" != "cola2_msgs" ]; then
      echo "--- Pushing version bumps to ${pkg}"
      cd $repo
      git push
      cd ..
    fi
  done < $3
fi
