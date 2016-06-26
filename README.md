# Linux virtio_scsi driver RHEL5 / CentOS5 Backport

## Overview

This package contains the virtio_scsi driver as backported originally from 3.3
to 2.6.39 and now to 2.6.18 RHEL5 / CentOS5 kernels.  These kernels
already have some virtio devices backported to it including virtio_net
and virtio_blk, but do not support virtio_scsi directly.

This driver allows using these older kernels on with virtio_scsi devices and
works with implementations such as qemu and Google Compute Engine.

This is not an official Google product.

## Building

This code distribution can work in one of two forms:

### Direct KBuild invocation

This driver can be invoked from the top-level directory of configured and built
kernel sources:

```
  $ cd ${HOME}/rpm/BUILD/kernel-2.6.18/linux-2.6.18.x86_64/   # KSRC
  $ make M=${HOME}/virtio_scsi                                # this package
```

When invoking this way, the driver may require specifying whether it should use
find_vq(),del_vq() or find_vqs(),del_vqs().  This can be overriden on the build
using the *USE_FIND_VQS* flag:

```
  $ cd ${HOME}/rpm/BUILD/kernel-2.6.18/linux-2.6.18.x86_64/   # KSRC
  $ make M=${HOME}/virtio_scsi USE_FIND_VQS=1
```

### Building RPMs

By default, when "make" is run, it will use the included kmodtool to configure
and build a kernel module package (.rpm).  By default, this will build against
the currently running kernel.  To build for another kernel version, be sure to
have installed the matching *kernel-devel* package and invoke "make" specifying
the *KVERSION* flag:

```
  $ make                                # builds rpms for current kernel
  $ make KVERSION=2.6.18-371.12.1.el5   # builds rpms for another version
```

## Booting with the driver (initrd setup)

Be sure to rebuild your initrd to ensure that the driver is available when
looking for the boot disk.  This is done using mkinitrd on RHEL5, using the
/--with/ flag to specify additional modules to include. *The virtio_pci driver
must also be installed/available in the initrd! otherwise your device will not
be found!*:

```
  $ sudo /sbin/mkinitrd --with virtio_scsi --with virtio_pci \
      /boot/initrd-2.6.18-164.el5.img 2.6.18-164.el5
```
