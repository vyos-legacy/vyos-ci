# vyos-ci

This repository should serve as a Demo on how to build the VyOS Linux Kernel
with out-of-tree modules as a Jenkins Pipeline job.

First it will fetch the Pipeline configuration from Git and later on will
grab all required source repositories, kernel, wireguard and accel-ppp.

Once Kernel has been compiled, a subsequent parallel run is started to compile
all out-of-tree modules specified in the parallel stage against the latest
Kernel configuration. This is required as - depending on the Kernel
configuration - the internal ABI might change resulting in symbol lookup
errors. This happened during release of VyOS 1.2.0-rc9 and should not re-occur.
