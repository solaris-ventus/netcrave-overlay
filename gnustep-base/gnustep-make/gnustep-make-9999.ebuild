# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnustep-base/gnustep-make/gnustep-make-2.6.2-r2.ebuild,v 1.1 2012/07/03 18:23:12 voyageur Exp $

EAPI=5
inherit gnustep-base eutils prefix toolchain-funcs subversion

DESCRIPTION="GNUstep Makefile Package"
HOMEPAGE="http://www.gnustep.org"
SRC_URI=""
ESVN_REPO_URI="svn://svn.gna.org/svn/gnustep/tools/make/trunk"
ESVN_PROJECT="gnustep-make"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="netcrave"
IUSE=""

DEPEND="${GNUSTEP_CORE_DEPEND}
	>=sys-devel/make-3.75
	>=sys-devel/clang-2.9"
RDEPEND="${DEPEND}"

pkg_setup() {
	libobjc_version=libobjc.so.4

	# For existing installations, determine if we will use another libobjc.so
	if has_version gnustep-base/gnustep-make; then
		local current_libobjc="$(awk -F: '/^OBJC_LIB_FLAG/ {print $2}' ${EPREFIX}/usr/share/GNUstep/Makefiles/config.make)"
		# Old installations did not set this explicitely
		: ${current_libobjc:=libobjc.so.2}

		if [[ ${current_libobjc} != ${libobjc_version} ]]; then
			ewarn "Warning: changed libobjc.so version!!"
			ewarn "The libobjc.so version used for gnustep-make has changed"
			ewarn "(either by the libojbc2 use-flag or a GCC upgrade)"
			ewarn "You must rebuild all gnustep packages installed."
			ewarn ""
			ewarn "To do so, please emerge gnustep-base/gnustep-updater and run:"
			ewarn "# gnustep-updater -l"
		fi
	fi

	export CC=clang
}

src_prepare() {
	# Multilib-strict
	sed -e "s#/lib#/$(get_libdir)#" -i FilesystemLayouts/fhs-system || die "sed failed"
	epatch "${FILESDIR}"/${PN}-2.0.1-destdir.patch
	cp "${FILESDIR}"/gnustep-4.{csh,sh} "${T}"/
	eprefixify "${T}"/gnustep-4.{csh,sh}
}

src_configure() {
	#--enable-objc-nonfragile-abi: only working in clang for now
	econf \
		--with-layout=fhs-system \
		--with-config-file="${EPREFIX}"/etc/GNUstep/GNUstep.conf \
		--with-objc-lib-flag=-l:${libobjc_version} \
	--enable-native-objc-exceptions --enable-objc-nonfragile-abi
}

src_compile() {
	emake
	# Prepare doc here (needed when no gnustep-make is already installed)
	if use doc ; then
		# If a gnustep-1 environment is set
		unset GNUSTEP_MAKEFILES
		pushd Documentation &> /dev/null
		emake all install
		popd &> /dev/null
	fi
}

src_install() {
	# Get GNUSTEP_* variables
	. ./GNUstep.conf

	export GNUSTEP_INSTALL_TYPE=SYSTEM

	local make_eval
	use debug || make_eval="${make_eval} debug=no"
	make_eval="${make_eval} verbose=yes"

	emake ${make_eval} DESTDIR="${D}" install

	# Copy the documentation
	if use doc ; then
		dodir ${GNUSTEP_SYSTEM_DOC}
		cp -r Documentation/tmp-installation/System/Library/Documentation/* \
			"${ED}"${GNUSTEP_SYSTEM_DOC=}
	fi

	dodoc FAQ README RELEASENOTES

	exeinto /etc/profile.d
	doexe "${T}"/gnustep-4.sh
	doexe "${T}"/gnustep-4.csh
}

pkg_postinst() {
	# Warn about new layout if old GNUstep directory is still here
	if [ -e /usr/GNUstep/System ]; then
		ewarn "Old layout directory detected (/usr/GNUstep/System)"
		ewarn "Gentoo has switched to FHS layout for GNUstep packages"
		ewarn "You must first update the configuration files from this package,"
		ewarn "then remerge all packages still installed with the old layout"
		ewarn "You can use gnustep-base/gnustep-updater for this task"
	fi
}
