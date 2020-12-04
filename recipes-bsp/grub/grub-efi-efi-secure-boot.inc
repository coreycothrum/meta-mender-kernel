FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
PASSWD_FILE_MD5X         = "aa25087bf6cc1c7a3ea7147c0bfbbcfc"

do_compile_append() {
  ##############################################################################
  sed -i '/search.file/d' ${WORKDIR}/cfg

  ##############################################################################
  local PASSWD_FILE="${WORKDIR}/password.inc"
  local PASSWD_FILE_MD5="$(md5sum ${PASSWD_FILE} | cut -d ' ' -f1)"

  if [ "${PASSWD_FILE_MD5X}" == "${PASSWD_FILE_MD5}" ]; then
    bbwarn "a custom layer should provide a replacement for stock password.inc"
  fi

  if grep -i "password " "${PASSWD_FILE}"; then
    bbwarn "plaintext password.inc should be replaced with grub-mkpasswd-pbkdf2 generated hash"
  fi
}
