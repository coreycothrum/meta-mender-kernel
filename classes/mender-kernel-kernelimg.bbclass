################################################################################
IMAGE_CMD_kernelimg() {
  local force_flag=""
  local root_dir_flag=""

  if [ ${MENDER/KERNEL_PART_SIZE_MB} -ne 0 ]; then
    if [ ${MENDER/KERNEL_PART_FSTYPE_TO_GEN} = "btrfs" ]; then
      force_flag="-f"
      root_dir_flag="-r"
    else
      force_flag="-F"
      root_dir_flag="-d"
    fi

    local KERN_FNAME="kernel.${MENDER/KERNEL_PART_FSTYPE_TO_GEN}"

    local SIZE="${@mender_kernel_calc_dir_size_mb("${DEPLOY_DIR_IMAGE}/${MENDER/KERNEL_KERN_BUILD_STAGING_DIR}")}"
    if [ "$SIZE" -ge "${MENDER/KERNEL_PART_SIZE_MB}" ]; then
      bbfatal        "${MENDER/KERNEL_PART_SIZE_MB} MB is too small, attempted to write $SIZE MB to kernelimg"
    fi

    rm -f              "${WORKDIR}/${KERN_FNAME}"
    dd if=/dev/zero of="${WORKDIR}/${KERN_FNAME}" count=0 bs=1M seek=${MENDER/KERNEL_PART_SIZE_MB}

    mkfs.${MENDER/KERNEL_PART_FSTYPE_TO_GEN}                                       \
      $force_flag                                                                  \
      "${WORKDIR}/${KERN_FNAME}"                                                   \
      -L kernel                                                                    \
      $root_dir_flag "${DEPLOY_DIR_IMAGE}/${MENDER/KERNEL_KERN_BUILD_STAGING_DIR}" \
      ${MENDER/KERNEL_PART_FSOPTS}

    rm      -f                                 "${IMGDEPLOYDIR}/${IMAGE_NAME}.kernelimg"
    install -m 0644 "${WORKDIR}/${KERN_FNAME}" "${IMGDEPLOYDIR}/${IMAGE_NAME}.kernelimg"
  fi
}

################################################################################
python () {
  if d.getVar('INITRAMFS_IMAGE')       : d.appendVarFlag('do_image_kernelimg', 'depends', ' ${INITRAMFS_IMAGE}:do_image_complete')
  if d.getVar('INITRAMFS_IMAGE_BUNDLE'): d.appendVarFlag('do_image_kernelimg', 'depends', ' virtual/kernel:do_bundle_initramfs')
}

################################################################################
do_image_kernelimg[respect_exclude_path] = "0"
do_image_kernelimg[nostamp]  = "1"

do_image_kernelimg[depends] += "rsync-native:do_populate_sysroot"
do_image_kernelimg[depends] += "virtual/kernel:do_build"

do_image_kernelimg[depends] += "${@bb.utils.contains    ('DISTRO_FEATURES'                 , 'mender-image-ubi', 'mtd-utils-native:do_populate_sysroot'  , '', d)}"
do_image_kernelimg[depends] += "${@bb.utils.contains    ('MENDER/KERNEL_PART_FSTYPE_TO_GEN', 'btrfs'           , 'btrfs-tools-native:do_populate_sysroot', '', d)}"
do_image_kernelimg[depends] += "${@bb.utils.contains_any('MENDER/KERNEL_PART_FSTYPE_TO_GEN', 'ext2 ext3 ext4'  , 'e2fsprogs-native:do_populate_sysroot'  , '', d)}"

################################################################################
