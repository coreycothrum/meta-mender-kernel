SUMMARY           = "mender-kernel basic /init script"
LICENSE           = "MIT"
LIC_FILES_CHKSUM  = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI           = "file://mender-kernel-init.sh"
FILES:${PN}       = "                   \
                      /init             \
                      /dev              \
                    "
RCONFLICTS:${PN} += "                   \
                      systemd-initramfs \
                    "
RDEPENDS:${PN}    = "                   \
                      coreutils         \
                      kmod              \
                      util-linux        \
                    "

inherit bitbake-variable-substitution

do_install () {
  install -m 0755 ${WORKDIR}/mender-kernel-init.sh ${D}/init
}

inherit allarch
