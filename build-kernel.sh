#!/bin/bash
ARCH=$(dpkg --print-architecture)

case "$ARCH" in
    amd64)
        make x86_64_vyos_defconfig
        echo $(make kernelversion)-amd64-vyos > ../kernel-version
        make bindeb-pkg LOCALVERSION='-amd64-vyos' KDEB_PKGVERSION=$(make kernelversion)-1 -j $(getconf _NPROCESSORS_ONLN)
    ;;

    armhf)
        make armhf_vyos_defconfig
    ;;
esac

