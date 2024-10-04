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
    install -d      ${D}/dev
    mknod   -m 0600 ${D}/dev/console c 5 1
    mknod   -m 0600 ${D}/dev/null    c 1 3
    mknod   -m 0600 ${D}/dev/zero    c 1 5

    install -m 0755 ${WORKDIR}/mender-kernel-init.sh ${D}/init
}

inherit allarch
