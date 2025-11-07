SUMMARY          = "Mender state script to update separate A/B kernel partitions"
DESCRIPTION      = "Mender state script to update separate A/B kernel partitions"
LICENSE          = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

################################################################################
RDEPENDS:${PN} = " \
  coreutils        \
  rsync            \
  util-linux       \
"

SRC_URI = "                             \
  file://abort-if-update-in-progress.sh \
  file://cleanup.sh                     \
  file://write-kernel-part.sh           \
"

inherit bitbake-variable-substitution-helpers
inherit mender-state-scripts

do_compile() {
  cp ${WORKDIR}/abort-if-update-in-progress.sh ${MENDER_STATE_SCRIPTS_DIR}/Download_Enter_00_mender-kernel-abort-if-update-in-progress.sh
  cp ${WORKDIR}/write-kernel-part.sh           ${MENDER_STATE_SCRIPTS_DIR}/ArtifactInstall_Enter_05_mender-kernel-write-kernel-part.sh
  cp ${WORKDIR}/cleanup.sh                     ${MENDER_STATE_SCRIPTS_DIR}/ArtifactInstall_Leave_05_mender-kernel-cleanup.sh
  cp ${WORKDIR}/cleanup.sh                     ${MENDER_STATE_SCRIPTS_DIR}/ArtifactInstall_Error_05_mender-kernel-cleanup.sh

  ${@bitbake_variables_search_and_sub(        "${MENDER_STATE_SCRIPTS_DIR}/", r"${BITBAKE_VAR_SUB_DELIM}", d)}
}

ALLOW_EMPTY:${PN} = "1"
