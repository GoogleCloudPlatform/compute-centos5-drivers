# Copyright 2016 Google Inc.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
# USA.

# This Makefile only contains stuff consumed by kbuild!
#
# Look at the GNUmakefile for top-level "make" entry.
obj-m += virtio_scsi.o
ifdef USE_FIND_VQS
CFLAGS_virtio_scsi.o := -DUSE_FIND_VQS=${USE_FIND_VQS}
endif
