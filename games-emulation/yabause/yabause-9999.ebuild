# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-emulation/yabause/yabause-0.9.14.ebuild,v 1.1 2015/02/09 21:39:51 mr_bones_ Exp $

EAPI=5
inherit git-2 eutils cmake-utils games

DESCRIPTION="A Sega Saturn emulator"
HOMEPAGE="http://yabause.org/"
#SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
EGIT_REPO_URI="https://github.com/Guillaumito/yabause.git"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="netcrave"
IUSE="openal opengl qt5 sdl"

# x11-libs/libXrandr is an automagic dep
# qt5 over qt4 and libsdl2 over libsdl is
# also done automatically.  Send patches
# upstream to make the choices explicit.
RDEPEND="
	x11-libs/libXrandr
	openal? ( media-libs/openal )
	opengl? (
		media-libs/freeglut
		virtual/glu
		virtual/opengl
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtwidgets:5[opengl?]
		opengl? ( dev-qt/qtopengl:5 )
	)
	!qt5? (
		dev-libs/glib:2
		x11-libs/gtk+:2
		x11-libs/gtkglext
	)
	sdl? ( media-libs/libsdl2[opengl?,video] )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_unpack() {
        git-2_src_unpack
}

#src_prepare() {
	#epatch "${FILESDIR}"/${P}-RWX.patch \
	#	"${FILESDIR}"/${P}-cmake.patch
#}

src_configure() {
	cd "${S}/yabause/" || die
	mv * ../
	CFLAGS="${CFLAGS} -fPIC"
	LDFLAGS="${LDFLAGS} -fPIC"
	local mycmakeargs=(
		-DBINDIR="${GAMES_BINDIR}"
		-DTRANSDIR="${GAMES_DATADIR}"/${PN}/yts
		-DYAB_OPTIMIZATION=""
		$(cmake-utils_use sdl YAB_WANT_SDL)
		$(cmake-utils_use openal YAB_WANT_OPENAL)
		$(cmake-utils_use opengl YAB_WANT_OPENGL)
		-DYAB_PORTS=$(usex qt5 "qt" "gtk")
	)
	cmake-utils_src_configure
}

src_compile() {
        CFLAGS="${CFLAGS} -fPIC"
	LDFLAGS="${LDFLAGS} -fPIC"
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
	dodoc AUTHORS ChangeLog GOALS README README.LIN
	prepgamesdirs
}
