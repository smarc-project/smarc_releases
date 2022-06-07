# Releasing packages into the SMARC package repository

## User guide

You can check [the released SMARC package](https://github.com/smarc-project/rosinstall/blob/master/rosdep/melodic/smarc.yaml)
to see if your package has been released. If you want to update one of them or release a new one,
follow the steps below.

### Install rules

All executables and libraries need install rules in order to be released.
See the bottom of [the catkin cmake docs](http://wiki.ros.org/catkin/CMakeLists.txt) for instructions.
Or look at [an example](https://github.com/smarc-project/sam_stonefish_sim/blob/noetic-devel/CMakeLists.txt).
Test locally by configuring your workspace with `catkin config --install`.
After sourcing `install/setup.bash`, your package should run as normal.

### Add package (not needed for updates)

#### Release file

For a multi-package repo, you need to add your package to the `release_packages.yaml` file in the root of
the repo. If the package depends on other packages in the repo, they also need to be released in this file.
The order matters, packages that are dependencies of others need to appear before those in the file.
See [this file](https://github.com/smarc-project/lolo_common/blob/noetic-devel/release_packages.yaml) for an example setup.
Here, `lolo_drivers` depends on `lolo_msgs`, and therefore appears later in the file.

#### Rosdep file

The first time you release a package, you also need to add
entries to the rosdep registries for [melodic](https://github.com/smarc-project/rosinstall/blob/master/rosdep/melodic/smarc.yaml)
and [noetic](https://github.com/smarc-project/rosinstall/blob/master/rosdep/noetic/smarc.yaml)
and submit a PR with the change. See the other entries for examples on how it should look.

### Update package version (only needed for updates)

Increment the version in your package's `package.xml` file. It contains three numbers: `X.Y.Z`.
The following number should be incremented depending on the size of the update:
* `X` if a major breaking change (very unusual, do with caution)
* `Y` if the update is major
* `Z` if it is a bug fix or small improvement

### Build and add new package or update

Ping @ozer or @jollerprutt, preferrably when submitting the pull request with the new changes.
Since the package might not build on the release server if there errors, this may take a few iterations back and forth.
