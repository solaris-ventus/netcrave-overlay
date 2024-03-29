# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-irc/unrealircd/unrealircd-3.2.10.4.ebuild,v 1.2 2014/09/30 07:54:01 nimiux Exp $

EAPI=4

inherit git-r3 autotools autotools-utils

DESCRIPTION="general-purpose software audio FSK modem."
HOMEPAGE="https://github.com/kamalmostafa/minimodem"
SRC_URI=""
SLOT="0"

EGIT_REPO_URI="https://github.com/kamalmostafa/minimodem.git"

LICENSE="GPL-2"

KEYWORDS="netcrave"

IUSE="deafteletype"

src_prepare() {
	eautoreconf
}

src_unpack() {
	git-r3_fetch
	git-r3_checkout

	if use deafteletype; then
		cd "${S}"
		epatch "${FILESDIR}/paigeadele_tty-tdd.patch"
	fi
}

src_configure() {
	autotools-utils_src_configure
}

src_compile() {
       autotools-utils_src_compile
}

src_install() {
        autotools-utils_src_install
}
