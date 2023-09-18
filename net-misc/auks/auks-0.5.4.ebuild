# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools systemd flag-o-matic

DESCRIPTION="Kerberos credential support for batch environments"
HOMEPAGE="https://github.com/cea-hpc/auks"

SRC_URI="https://github.com/cea-hpc/auks/archive/refs/tags/${PV}.tar.gz"

LICENSE="CeCILL-C"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+slurm"

RDEPEND="
>=app-crypt/mit-krb5-1.18
slurm? ( sys-cluster/slurm )
"
DEPEND="${RDEPEND}"
BDEPEND="sys-devel/automake"

PATCHES=(
	"${FILESDIR}/${PN}-fix-sysconfigdir.patch"
)

src_prepare() {
	default
	einfo "Regenerating autotools files..."
	eautoreconf
}

src_configure() {
	if use slurm; then
		myconf+="--with-slurm"
	fi
	econf \
		${myconf}
}

src_install() {
	default
	systemd_dounit ${FILESDIR}/*.service
	insinto /etc/logrotate.d
	newins ${FILESDIR}/${PN}.logrotate ${PN}
	keepdir /etc/auks
}
