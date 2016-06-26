DRIVER=virtio_scsi
SOURCES=Makefile virtio_scsi.c virtio_scsi.h
KMODTOOL=kmodtool-virtio_scsi-el5.sh
SPEC=kmod-virtio_scsi.spec

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
rpm/SPECS/${SPEC}: ${SPEC} ${RPMDIR_HOLDERS}
	cp -f $< $@
STAGED_SOURCES:=$(addprefix rpm/SOURCES/${PACKAGE}/,${SOURCES})
STAGED_KMODTOOL:=$(addprefix rpm/SOURCES/,${KMODTOOL})
${STAGED_KMODTOOL}: ${KMODTOOL} ${RPMDIR_HOLDERS}
	cp -f ${KMODTOOL} rpm/SOURCES/
${RPMS}: ${TARBALL} rpm/SPECS/${SPEC} ${STAGED_KMODTOOL}
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
		cp -f $$i rpm/SOURCES/${PACKAGE}/$$i ; \
	done
clean:
	rm -rf rpm/
	rm -rf .tmp_versions/
	rm -f .*.cmd
	rm -f Module.markers
	rm -f Module.symvers
	rm -f *.ko
	rm -f *.o
	rm -f *.mod.c
