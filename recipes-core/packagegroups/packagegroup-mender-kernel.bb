DESCRIPTION = "meta-mender-kernel core packages"
SUMMARY     = "meta-mender-kernel core packages"

inherit packagegroup

RDEPENDS_${PN} = "            \
  mender-kernel-state-scripts \
"
