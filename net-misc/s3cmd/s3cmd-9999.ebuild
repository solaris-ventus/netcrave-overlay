# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/s3cmd/s3cmd-1.5.2-r1.ebuild,v 1.1 2015/03/31 01:51:53 idella4 Exp $

EAPI=5

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="xml"

inherit distutils-r1 git-r3

DESCRIPTION="Command line client for Amazon S3"
HOMEPAGE="http://s3tools.org/s3cmd"
EGIT_REPO_URI="https://github.com/s3tools/s3cmd.git"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="netcrave"
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/python-magic[${PYTHON_USEDEP}]"


python_install_all() {
	# setup/py doesn't intereact well with the eclass
	distutils-r1_python_install_all
}
