# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

MULTILIB_COMPAT=( abi_x86_{32,64} )
inherit eutils linux-info multilib-build unpacker

DESCRIPTION="AMD GPU-Pro kernel module for Radeon Evergreen (HD5000 Series) and newer chipsets"
HOMEPAGE="http://support.amd.com/en-us/kb-articles/Pages/AMD-Radeon-GPU-PRO-Linux-Beta-Driver%E2%80%93Release-Notes.aspx"

#amdgpu-pro-16.40-348864.tar.xz
BUILD_VER=16.40-348864

SRC_URI="https://www2.ati.com/drivers/beta/amdgpu-pro-${BUILD_VER}.tar.xz"
RESTRICT="fetch strip"

# We cannot use dkms from within ebuild as it tries to modify the live filesystem.
LICENSE="AMD GPL-2 QPL-1.0"
KEYWORDS="netcrave"
SLOT=${BUILD_VER}

RDEPEND="
	sys-kernel/dkms
"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - amdgpu-pro_${BUILD_VER}.tar.xz for Ubuntu 16.04"
	einfo "from ${HOMEPAGE} and place them in ${DISTDIR}"
}

unpack_deb() {
	echo ">>> Unpacking ${1##*/} to ${PWD}"
	unpack $1
	unpacker ./data.tar*

	# Clean things up #458658.  No one seems to actually care about
	# these, so wait until someone requests to do something else ...
	rm -f debian-binary {control,data}.tar*
}

src_prepare() {
	linux-info_pkg_setup

	unpack_deb "./amdgpu-pro-${BUILD_VER}/amdgpu-pro-dkms_${BUILD_VER}_all.deb"

	rm -rf ./usr/share amdgpu-pro-${BUILD_VER} ./usr/src/amdgpu-pro-${BUILD_VER}/firmware

	pushd ./usr/src/amdgpu-pro-${BUILD_VER} > /dev/null
		epatch "${FILESDIR}"/0002-Add-in-Gentoo-as-an-option-for-the-OS-otherwise-it-w.patch
		epatch "${FILESDIR}"/0005-update-kcl_ttm_bo_reserve-for-linux-4.7.patch
		epatch "${FILESDIR}"/0009-Change-name-of-vblank_disable_allowed-to-vblank_disa.patch
		epatch "${FILESDIR}"/0010-Remove-connector-parameter-from-__drm_atomic_helper_.patch
		epatch "${FILESDIR}"/0012-disable-dal-by-default.patch
		# Dont copy the firmware
		head -n -4 ./pre-build.sh > ./pre-build.sh.new
		mv ./pre-build.sh.new ./pre-build.sh
		chmod +x ./pre-build.sh
	popd > /dev/null
}

src_install() {
	cp -R -t "${D}" * || die "Install failed!"
}

pkg_postinst() {
	elog "To install the kernel module, you need to do the following:"
	elog ""
	elog "  dkms add -m amdgpu-pro -v ${BUILD_VER}"
	elog "  dkms build -m amdgpu-pro -v ${BUILD_VER} (-k <desired kernel version>)"
	elog "  dkms install -m amdgpu-pro -v ${BUILD_VER} (-k <desired kernel version>)"
}

pkg_postrm() {
	elog "If you have built and installed the kernel module, to remove it, you need to do the following:"
	elog ""
	elog "  dkms remove -m amdgpu-pro -v ${BUILD_VER} --all"
	elog ""
	elog "If you haven't, just:"
	elog "  rm -rf /var/lib/dkms/amdgpu-pro"
}
