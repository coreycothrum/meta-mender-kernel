DESCRIPTION = "meta-mender-kernel core packages"
SUMMARY     = "meta-mender-kernel core packages"

inherit packagegroup

RDEPENDS:${PN}  = "                                                                                  \
  mender-kernel-state-scripts                                                                        \
                                                                                                     \
  ${@bb.utils.contains("DISTRO_FEATURES", "efi-secure-boot", "packagegroup-efi-secure-boot", "", d)} \
"
