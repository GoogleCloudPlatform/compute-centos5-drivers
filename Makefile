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

DRIVER=virtio_scsi
SOURCES=LICENSE README.md \
  $(addprefix third_party/virtio_scsi/,Makefile virtio_scsi.c virtio_scsi.h)
KMODTOOL=third_party/redhat_rpm_config/kmodtool-virtio_scsi-el5.sh
SPEC=third_party/centos/kmod-virtio_scsi.spec

# Overridable variables on the command line:
KVERSION=$(shell uname -r)
override KVERSION:=$(strip $(KVERSION)$(if $(filter $(origin KVERSION),file),\
  $(info INFO: Building for current kernel $(KVERSION) -- override by setting $$KVERSION)))

# Extract driver version info from the .spec file:
VERSION=$(shell sed -n 's/^Version: \(.*\)/\1/p' ${SPEC})
RELEASE=$(shell sed -n 's/^Release: \(.*\)/\1/p' ${SPEC})

# Packaging logic: this works by staging (copying) SOURCES into a tree which
# is then tarballed and passed on as the hermetic source package to rpmbuild.
PACKAGE=${DRIVER}-${VERSION}
RPMS=rpm/RPMS/x86_64/kmod-${DRIVER}-${KVERSION}-${VERSION}-${RELEASE}.x86_64.rpm \
     rpm/SRPMS/${DRIVER}-kmod-${VERSION}-${RELEASE}.src.rpm
all: ${RPMS}
TARBALL=rpm/SOURCES/${PACKAGE}.tar.bz2
# Use placeholder files to stage the rpmbuild tree
RPMDIR_HOLDERS=$(addsuffix /.hold,$(addprefix rpm/,BUILD RPMS SOURCES SPECS SRPMS))
${RPMDIR_HOLDERS}:
	mkdir -p $$(dirname $@) && touch $@
STAGED_SPEC=rpm/SPECS/$(notdir ${SPEC})
${STAGED_SPEC}: ${SPEC} ${RPMDIR_HOLDERS}
	cp -f $< $@
STAGED_SOURCES:=$(addprefix rpm/SOURCES/${PACKAGE}/,$(notdir ${SOURCES}))
STAGED_KMODTOOL:=$(addprefix rpm/SOURCES/,${KMODTOOL})
${STAGED_KMODTOOL}: ${KMODTOOL} ${RPMDIR_HOLDERS}
	cp -f ${KMODTOOL} rpm/SOURCES/
${RPMS}: ${TARBALL} ${STAGED_SPEC} ${STAGED_KMODTOOL}
	rpmbuild -ba \
	  --define "_topdir $$(pwd)/rpm" \
	  --define "VERSION ${VERSION}" \
	  --define "RELEASE ${RELEASE}" \
	  --define 'kversion $(KVERSION)' \
	  rpm/SPECS/kmod-virtio_scsi.spec
${TARBALL}: ${STAGED_SOURCES}
	cd rpm/SOURCES ; \
	tar -jcf ${PACKAGE}.tar.bz2 ${PACKAGE}
${STAGED_SOURCES}: ${SOURCES}
	mkdir -p rpm/SOURCES/${PACKAGE} ; \
	for i in ${SOURCES} ; do \
		cp -f $$i rpm/SOURCES/${PACKAGE}/$$(basename $$i) ; \
	done
clean:
	rm -rf rpm/
	rm -rf third_party/virtio_scsi/.tmp_versions/
	rm -f third_party/virtio_scsi/.*.cmd
	rm -f third_party/virtio_scsi/Module.markers
	rm -f third_party/virtio_scsi/Module.symvers
	rm -f third_party/virtio_scsi/*.ko
	rm -f third_party/virtio_scsi/*.o
	rm -f third_party/virtio_scsi/*.mod.c
