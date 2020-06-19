IMAGE_CMD_kernelimg() {
  local PATH=$PATH:/sbin:/bin:/usr/sbin:/usr/bin

  if [ ${MENDER/KERNEL_PART_SIZE_MB} -ne 0 ]; then
    if [ ${MENDER/KERNEL_PART_FSTYPE_TO_GEN} = "btrfs" ]; then
      force_flag="-f"
      root_dir_flag="-r"
    else
      force_flag="-F"
      root_dir_flag="-d"
    fi

    local BOOT_DIR="$(dirname ${MENDER_BOOT_PART_MOUNT_LOCATION})"
    local KERN_FNAME="kernel.${MENDER/KERNEL_PART_FSTYPE_TO_GEN}"
    local STAGING_DIR="kernel_staging/"

    rm    -fr                                "${WORKDIR}/${STAGING_DIR}"
    mkdir -p                                 "${WORKDIR}/${STAGING_DIR}"
    rsync -avq "${IMAGE_ROOTFS}${BOOT_DIR}/" "${WORKDIR}/${STAGING_DIR}" --exclude "$(basename ${MENDER_BOOT_PART_MOUNT_LOCATION})"

    rm -f              "${WORKDIR}/${KERN_FNAME}"
    dd if=/dev/zero of="${WORKDIR}/${KERN_FNAME}" count=0 bs=1M seek=${MENDER/KERNEL_PART_SIZE_MB}

    mkfs.${MENDER/KERNEL_PART_FSTYPE_TO_GEN}     \
      $force_flag                                \
      "${WORKDIR}/${KERN_FNAME}"                 \
      -L kernel                                  \
      $root_dir_flag "${WORKDIR}/${STAGING_DIR}" \
      ${MENDER/KERNEL_PART_FSOPTS}

    rm      -fr                                "${WORKDIR}/${STAGING_DIR}"
    rm      -f                                 "${IMGDEPLOYDIR}/${IMAGE_NAME}.kernelimg"
    install -m 0644 "${WORKDIR}/${KERN_FNAME}" "${IMGDEPLOYDIR}/${IMAGE_NAME}.kernelimg"
  fi
}

do_mender_kernel_copy_bundle_or_initramfs() {
  local BOOT_DIR="$(dirname ${MENDER_BOOT_PART_MOUNT_LOCATION})"

  if [ "${INITRAMFS_IMAGE_BUNDLE}" -eq "1" -a -n "${INITRAMFS_IMAGE}" ]; then
    rm -r                                                                               "${IMAGE_ROOTFS}${BOOT_DIR}/${KERNEL_IMAGETYPE}"*
    cp         "${DEPLOY_DIR_IMAGE}/${KERNEL_IMAGETYPE}-${INITRAMFS_IMAGE}.bin"         "${IMAGE_ROOTFS}${BOOT_DIR}/"
    lnr "${IMAGE_ROOTFS}${BOOT_DIR}/${KERNEL_IMAGETYPE}-${INITRAMFS_IMAGE}.bin"         "${IMAGE_ROOTFS}${BOOT_DIR}/${KERNEL_IMAGETYPE}"
  elif [ -n "${INITRAMFS_IMAGE}" ]; then
    rm -r                                                                               "${IMAGE_ROOTFS}${BOOT_DIR}/${MENDER/KERNEL_INITRAMFS_LINK_NAME}"*
    cp         "${DEPLOY_DIR_IMAGE}/${INITRAMFS_IMAGE}-${MACHINE}.${INITRAMFS_FSTYPES}" "${IMAGE_ROOTFS}${BOOT_DIR}/"
    lnr "${IMAGE_ROOTFS}${BOOT_DIR}/${INITRAMFS_IMAGE}-${MACHINE}.${INITRAMFS_FSTYPES}" "${IMAGE_ROOTFS}${BOOT_DIR}/${MENDER/KERNEL_INITRAMFS_LINK_NAME}"
  else
    bbplain "meta-mender-kernel: no initramfs or kernel bundle defined"
  fi
}
addtask mender_kernel_copy_bundle_or_initramfs after do_rootfs before do_image_kernelimg

python __anonymous () {
  if     d.getVar('INITRAMFS_IMAGE')                  : d.appendVarFlag('do_image_kernelimg', 'depends', '${INITRAMFS_IMAGE}:do_image_complete')
  if int(d.getVar('INITRAMFS_IMAGE_BUNDLE') or 0) is 1: d.appendVarFlag('do_image_kernelimg', 'depends', 'virtual/kernel:do_bundle_initramfs')
}

do_image_kernelimg[respect_exclude_path] = "0"
do_image_kernelimg[depends] += "${@bb.utils.contains    ('DISTRO_FEATURES'                 , 'mender-image-ubi'  , 'mtd-utils-native:do_populate_sysroot'  , '', d)}"
do_image_kernelimg[depends] += "${@bb.utils.contains    ('MENDER/KERNEL_PART_FSTYPE_TO_GEN', 'btrfs'             , 'btrfs-tools-native:do_populate_sysroot', '', d)}"
do_image_kernelimg[depends] += "${@bb.utils.contains_any('MENDER/KERNEL_PART_FSTYPE_TO_GEN', 'ext2 ext3 ext4'    , 'e2fsprogs-native:do_populate_sysroot'  , '', d)}"
