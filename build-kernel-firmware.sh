#!/bin/bash

basedir=$(pwd)
KERNEL_VER=$(cat $basedir/kernel-version)

LINUX_FW_COMMIT="9ee52be785cf91fc6a3c6aa27d484873f8270b72"
LINUX_FW_VERSION="1.3.0-0"
deb_pkg_dir="$basedir/vyos-firmware_${LINUX_FW_VERSION}_all"

mkdir -p $deb_pkg_dir/DEBIAN $deb_pkg_dir/lib
git clone --depth=1 https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git $deb_pkg_dir/lib/firmware
cd $deb_pkg_dir/lib/firmware
git checkout $LINUX_FW_COMMIT

echo "Package: vyos-firmware" >$deb_pkg_dir/DEBIAN/control
echo "Version: $LINUX_FW_VERSION" >>$deb_pkg_dir/DEBIAN/control
echo "Section: kernel" >>$deb_pkg_dir/DEBIAN/control
echo "Priority: extra" >>$deb_pkg_dir/DEBIAN/control
echo "Architecture: amd64" >>$deb_pkg_dir/DEBIAN/control
echo "Maintainer: VyOS Package Maintainers <maintainers@vyos.net>" >>$deb_pkg_dir/DEBIAN/control
echo "Installed-Size: 9" >>$deb_pkg_dir/DEBIAN/control
echo "Depends: linux-image" >>$deb_pkg_dir/DEBIAN/control
echo "Description: This repository contains all these firmware images" >>$deb_pkg_dir/DEBIAN/control
echo "  which have been extracted from older drivers, as well various" >>$deb_pkg_dir/DEBIAN/control
echo "  new firmware images which we were never permitted to include" >>$deb_pkg_dir/DEBIAN/control
echo "  in a GPL'd work, but which we _have_ been permitted to" >>$deb_pkg_dir/DEBIAN/control
echo "  redistribute under separate cover." >>$deb_pkg_dir/DEBIAN/control

cd $basedir

if [ "$deb_pkg_dir" != "/" ]; then
    # We do not need to pack up the git repository itself :)
    rm -rf $deb_pkg_dir/lib/firmware/.git

    # We are a router - no need for GPU firmware BLOBs
    rm -rf $deb_pkg_dir/lib/firmware/v4l-cx*
    rm -rf $deb_pkg_dir/lib/firmware/s5p-mfc*
    rm -rf $deb_pkg_dir/lib/firmware/nvidia
    rm -rf $deb_pkg_dir/lib/firmware/amdgpu
    rm -rf $deb_pkg_dir/lib/firmware/i915
fi

dpkg-deb --build $(basename $deb_pkg_dir)
