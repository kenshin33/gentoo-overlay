# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools systemd

DESCRIPTION="Kerberos credential support for batch environments"
HOMEPAGE="https://github.com/cea-hpc/auks"

SRC_URI="https://github.com/cea-hpc/auks/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CeCILL-C"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+slurm pam"

RDEPEND="
>=app-crypt/mit-krb5-1.18
slurm? ( sys-cluster/slurm )
pam? ( sys-libs/pam )
"
DEPEND="${RDEPEND}"
BDEPEND="sys-devel/automake"

PATCHES=(
	"${FILESDIR}"/${PN}-fix-sysconfigdir.patch
)

src_prepare() {
	default
	einfo "Regenerating autotools files..."
	eautoreconf
}

src_configure() {
	local myconf
	#neither --without-pam nor --without-slurm does what they're supposed to
	if use slurm; then
		myconf+="--with-slurm"
	fi
	if use pam; then
		myconf+="--with-pam"
	fi
	econf \
		${myconf}
}

src_install() {
	default
	systemd_dounit "${FILESDIR}"/*.service
	insinto /etc/logrotate.d
	newins "${FILESDIR}"/${PN}.logrotate ${PN}
	keepdir /etc/auks
	find "${ED}" -type f -name '*.la' -delete || die
}
