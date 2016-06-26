# This Makefile only contains stuff consumed by kbuild!
#
# Look at the GNUmakefile for top-level "make" entry.
obj-m += virtio_scsi.o
ifdef USE_FIND_VQS
CFLAGS_virtio_scsi.o := -DUSE_FIND_VQS=${USE_FIND_VQS}
endif
