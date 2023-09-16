# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools systemd flag-o-matic
DESCRIPTION="Kerberos credential support for batch environments"
HOMEPAGE="https://github.com/hautreux/auks"
#SRC_URI="https://github.com/hautreux/auks/archive/${PV}.tar.gz"
SRC_URI="https://github.com/cea-hpc/auks/archive/refs/tags/${PV}.tar.gz"
LICENSE=""
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+slurm +systemd"

DEPEND="
>=app-crypt/mit-krb5-1.18
slurm? ( sys-cluster/slurm )
"
RDEPEND="${DEPEND}"
BDEPEND="sys-devel/automake"

PATCHES=(
	"${FILESDIR}/${PN}-fix-service-files.patch"
)

src_prepare() {
	default
	einfo "Regenerating autotools files..."
	eautoreconf
}

src_configure() {
	local myconf
	append-cflags -DSYSCONFDIR=\\\"/etc/auks\\\"
	if use slurm; then
		myconf+="--with-slurm"
	fi
	econf \
		${myconf}
}

src_install() {
	default
	if use systemd; then
		systemd_dounit ${FILESDIR}/*.service
	fi
	insinto /etc/logrotate.d
	newins ${FILESDIR}/${PN}.logrotate ${PN}
	#insinto /etc/${PN}
	#doins ${WORKDIR}/${P}/etc/*.example

}
