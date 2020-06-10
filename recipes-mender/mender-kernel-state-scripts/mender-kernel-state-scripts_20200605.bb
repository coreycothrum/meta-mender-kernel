SUMMARY          = "Mender state script to update separate A/B kernel partitions"
DESCRIPTION      = "Mender state script to update separate A/B kernel partitions"
LICENSE          = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

################################################################################
RDEPENDS_${PN}   = "                  \
                     coreutils        \
                     rsync            \
                     util-linux       \
                     util-linux-mount \
                   "
SRC_URI          = "                             \
                     file://noop.sh              \
                     file://write-kernel-part.sh \
                   "

inherit mender-state-scripts
inherit mender-kernel-helpers

do_compile() {
  cp ${WORKDIR}/noop.sh              ${MENDER_STATE_SCRIPTS_DIR}/Download_Leave_00_noop.sh
  cp ${WORKDIR}/write-kernel-part.sh ${MENDER_STATE_SCRIPTS_DIR}/ArtifactInstall_Enter_05_write-kernel-part.sh

  "${@bitbake_variables_search_and_expand("${MENDER_STATE_SCRIPTS_DIR}", r"@@", d)}"
}
