#!/bin/bash
RELEASE=`echo $GIT_BRANCH | sed 's/origin\//* /g' |sed -n 's/^\* \(.*\)$/\1/p'`

#TOKEN=`cat ~/tokennr`
#REPO="vyos-kernel"

#curl -XPOST -H "Authorization: token $TOKEN" https://api.github.com/repos/vyos/$REPO/statuses/$(git rev-parse HEAD) -d "{
#  \"state\": \"pending\",
#  \"target_url\": \"${BUILD_URL}\",
#  \"description\": \"The build is pending!\",
#  \"context\": \"continuous-integration/jenkins\"
#}"

# newer Kernel versions come with a "# SPDX-License-Identifier: GPL-2.0" identifier
# as the first line in the file - use compatible approach with grep rather then sed
VERSION=$(grep "^VERSION" Makefile | grep -Eo '[0-9]{1,4}')
PATCHLEVEL=$(grep "^PATCHLEVEL" Makefile | grep -Eo '[0-9]{1,4}')
SUBLEVEL=$(grep "^SUBLEVEL" Makefile | grep -Eo '[0-9]{1,4}')
ARCH=$(dpkg --print-architecture)

case "$ARCH" in
    amd64)
        make x86_64_vyos_defconfig
        TARGETS="kernel_source kernel_debug kernel_headers kernel_image"
        # the following targets are not supported for Linux Kernels > 4.14 as
        # they have been removed from the Makefile (commits 18afab8c1d3c2 &
        # 22cba31bae9dc).
        if [ ${PATCHLEVEL} -lt 14 ]; then
            TARGETS+=" kernel_manual kernel_doc"
        fi
        echo "$VERSION.$PATCHLEVEL.$SUBLEVEL-amd64-vyos" > ../kernel-version
        LOCALVERSION="" make-kpkg --rootcmd fakeroot --initrd --append_to_version -amd64-vyos --revision=$VERSION.$PATCHLEVEL.$SUBLEVEL-1+vyos1+current1 ${TARGETS}
    ;;

    armhf)
        make armhf_vyos_defconfig
    ;;
esac

