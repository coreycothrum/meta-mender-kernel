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

    local BOOT_DIR="$(dirname ${MENDER_BOOT_PART_MOUNT_LOCATION})"
    local KERN_FNAME="kernel.${MENDER/KERNEL_PART_FSTYPE_TO_GEN}"
    local STAGING_DIR="kernel_staging/"

    rm    -fr                                      "${WORKDIR}/${STAGING_DIR}"
    mkdir -p                                       "${WORKDIR}/${STAGING_DIR}"
    rsync -avqI "${IMAGE_ROOTFS}${BOOT_DIR}/"      "${WORKDIR}/${STAGING_DIR}" --exclude "$(basename ${MENDER_BOOT_PART_MOUNT_LOCATION})"

    local  SIZE="${@mender_kernel_calc_dir_size_mb("${WORKDIR}/${STAGING_DIR}")}"
    if [ "$SIZE" -ge "${MENDER/KERNEL_PART_SIZE_MB}" ]; then
      bbfatal        "${MENDER/KERNEL_PART_SIZE_MB} MB is too small, attempted to write $SIZE MB to kernelimg"
    fi

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

################################################################################
do_mender_kernel_deploy_to_sysroot() {
  local BOOT_DIR="$(dirname ${MENDER_BOOT_PART_MOUNT_LOCATION})"

  local src_dir="${DEPLOY_DIR_IMAGE}"
  local dst_dir="${IMAGE_ROOTFS}${BOOT_DIR}"
  local sig_ext="${SB_FILE_EXT}"

  rm -f "$dst_dir/${KERNEL_IMAGETYPE}"*
  rm -f "$dst_dir/${MENDER/KERNEL_INITRAMFS_LINK_NAME}"*

  if [ "${INITRAMFS_IMAGE_BUNDLE}" -eq "1" ]; then
    for ktype in ${KERNEL_IMAGETYPES}; do
      local base_name="$ktype-${INITRAMFS_IMAGE}.bin"

      cp           "$src_dir/$base_name"* "$dst_dir/"
      for fname in "$dst_dir/$base_name"*
      do
        local fname_base="$(basename $fname)"
        local fname_ext="${fname_base##$base_name}"

        lnr "$fname" "$dst_dir/$ktype$fname_ext"
      done
    done
  else
    for ktype in ${KERNEL_IMAGETYPES}; do
      local base_name="$ktype"

      cp "$src_dir/$base_name"   "$dst_dir/"
      cp "$src_dir/$base_name".* "$dst_dir/" || :
    done

    if [ -n "${INITRAMFS_IMAGE}" ]; then
      for fstype in ${INITRAMFS_FSTYPES}; do
        local base_name="${INITRAMFS_IMAGE}-${MACHINE}.$fstype"

        cp           "$src_dir/$base_name"* "$dst_dir/"
        for fname in "$dst_dir/$base_name"*
        do
          local fname_base="$(basename $fname)"
          local fname_ext="${fname_base##$base_name}"

          lnr "$fname" "$dst_dir/${MENDER/KERNEL_INITRAMFS_LINK_NAME}$fname_ext"
        done
      done
    fi
  fi
}
addtask do_mender_kernel_deploy_to_sysroot after do_rootfs before do_image_kernelimg

################################################################################
################################################################################
# This task should be removed if/when SELoader can support verification of files
# outside the /efi partition.

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', 'user-key-store', '', d)}

python do_mender_kernel_sign_bundled_kernel() {
  # SELoader from meta-secure-core/meta-efi-secure-boot does not support verification
  # outside the /efi partition. sbsign the bundled kernel/initramfs for compat
  # with the grub chainloader command (i.e. use shim to verify).

  if not bb.utils.contains('DISTRO_FEATURES', 'efi-secure-boot', True, False, d):
    return True

  else:
    dst_dir = os.path.join( d.expand('${IMAGE_ROOTFS}')) + os.path.dirname(d.expand('${MENDER_BOOT_PART_MOUNT_LOCATION}'))
    sig_ext = d.expand('${SB_FILE_EXT}')

    files = os.listdir( dst_dir )
    for fname in files:
      if fname.endswith( sig_ext ):
        fpath = os.path.join( dst_dir, fname )
        spath = os.path.splitext(fpath)[0]

        os.remove( fpath )

        sb_sign(spath, spath, d)

    for ktype in d.expand('${KERNEL_IMAGETYPES}').split():
      bundle_img  = "%s-%s.bin" % ( ktype, d.expand('${INITRAMFS_IMAGE}') )
      bundle_path = os.path.join( dst_dir, bundle_img)

      sb_sign(bundle_path, bundle_path, d)
}
addtask do_mender_kernel_sign_bundled_kernel after do_mender_kernel_deploy_to_sysroot before do_image_kernelimg
################################################################################
################################################################################

################################################################################
python () {
  if d.getVar('INITRAMFS_IMAGE')       : d.appendVarFlag('do_image_kernelimg', 'depends', ' ${INITRAMFS_IMAGE}:do_image_complete')
  if d.getVar('INITRAMFS_IMAGE_BUNDLE'): d.appendVarFlag('do_image_kernelimg', 'depends', ' virtual/kernel:do_bundle_initramfs')

  fstypes    = d.getVar('IMAGE_FSTYPES') + " " + d.getVar("ARTIFACTIMG_FSTYPE")
  handled    = set()

  for image_type in fstypes.split():
    # add image deps, task(s)
    task = "do_image_%s" % image_type

    if not bb.data.inherits_class("image", d):
      continue

    if task in handled:
      continue

    d.appendVarFlag(task, "recrdeptask", " do_image_kernelimg")
    handled.add(task)
}

################################################################################
do_image_kernelimg[respect_exclude_path] = "0"
do_image_kernelimg[nostamp]  = "1"

do_image_kernelimg[depends] += "rsync-native:do_populate_sysroot"
do_image_kernelimg[depends] += "${@bb.utils.contains    ('DISTRO_FEATURES'                 , 'mender-image-ubi', 'mtd-utils-native:do_populate_sysroot'  , '', d)}"
do_image_kernelimg[depends] += "${@bb.utils.contains    ('MENDER/KERNEL_PART_FSTYPE_TO_GEN', 'btrfs'           , 'btrfs-tools-native:do_populate_sysroot', '', d)}"
do_image_kernelimg[depends] += "${@bb.utils.contains_any('MENDER/KERNEL_PART_FSTYPE_TO_GEN', 'ext2 ext3 ext4'  , 'e2fsprogs-native:do_populate_sysroot'  , '', d)}"
