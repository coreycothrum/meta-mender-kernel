IMAGE_CLASSES += "          \
  mender-kernel-helpers     \
  mender-kernel-kernelimg   \
  mender-kernel-part-images \
"

################################################################################
# setup kernel partitions (via MENDER_EXTRA_PARTS)
################################################################################
MENDER/KERNEL_PART_A_NAME                  = "kernela"
MENDER/KERNEL_PART_B_NAME                  = "kernelb"
MENDER/KERNEL_EXTRA_PARTS                  = "${MENDER/KERNEL_PART_A_NAME} ${MENDER/KERNEL_PART_B_NAME}"

MENDER_EXTRA_PARTS                        += "${MENDER/KERNEL_EXTRA_PARTS}"
MENDER_EXTRA_PARTS[kernela]                = "--label=${MENDER/KERNEL_PART_A____NAME} --source rawcopy --sourceparams=file=${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.kernelimg --fstype=${MENDER/KERNEL_PART_FSTYPE_TO_GEN}"
MENDER_EXTRA_PARTS[kernelb]                = "--label=${MENDER/KERNEL_PART_B____NAME} --source rawcopy --sourceparams=file=${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.kernelimg --fstype=${MENDER/KERNEL_PART_FSTYPE_TO_GEN}"
MENDER_EXTRA_PARTS_SIZES_MB[kernela]       = "${MENDER/KERNEL_PART_SIZE_MB}"
MENDER_EXTRA_PARTS_SIZES_MB[kernelb]       = "${MENDER/KERNEL_PART_SIZE_MB}"

MENDER/KERNEL_PART_A                       = "${MENDER_STORAGE_DEVICE_BASE}${MENDER/KERNEL_PART_A_NUMBER}"
MENDER/KERNEL_PART_A_NUMBER                = "${@mender_get_extra_parts_offset_by_id(d, "${MENDER/KERNEL_PART_A_NAME}")}"
MENDER/KERNEL_PART_B                       = "${MENDER_STORAGE_DEVICE_BASE}${MENDER/KERNEL_PART_B_NUMBER}"
MENDER/KERNEL_PART_B_NUMBER                = "${@mender_get_extra_parts_offset_by_id(d, "${MENDER/KERNEL_PART_B_NAME}")}"

MENDER/KERNEL_PART_FSOPTS                ??= "${MENDER/KERNEL_PART_FSOPTS_DEFAULT}"
MENDER/KERNEL_PART_FSOPTS_DEFAULT          = ""

MENDER/KERNEL_PART_FSTYPE                ??= "${MENDER/KERNEL_PART_FSTYPE_DEFAULT}"
MENDER/KERNEL_PART_FSTYPE_DEFAULT          = "auto"

MENDER/KERNEL_PART_FSTYPE_TO_GEN         ??= "${MENDER/KERNEL_PART_FSTYPE_TO_GEN_DEFAULT}"
MENDER/KERNEL_PART_FSTYPE_TO_GEN_DEFAULT   = "${@bb.utils.contains('MENDER/KERNEL_PART_FSTYPE', 'auto', '${ARTIFACTIMG_FSTYPE}', '${MENDER/KERNEL_PART_FSTYPE}', d)}"

MENDER/KERNEL_PART_SIZE_MB               ??= "${MENDER/KERNEL_PART_SIZE_MB_DEFAULT}"
MENDER/KERNEL_PART_SIZE_MB_DEFAULT         = "128"

MENDER/KERNEL_INITRAMFS_LINK_NAME        ??= "initramfs.img"

################################################################################
# build tasks
################################################################################
do_mender_kernel_update_fstab() {
  mender_kernel_delete_kernel_parts ${IMAGE_ROOTFS}${sysconfdir}/fstab
}
addtask mender_kernel_update_fstab after do_rootfs before do_image

python do_mender_kernel_checks() {
  if   bb.utils.contains('MENDER_FEATURES_ENABLE', 'mender-image-ubi', True, False, d):
    #I know nothing about ubi support, didn't need it and didn't have time to look into it
    bb.fatal("mender-kernel does not currently support mender-image-ubi")

  elif bb.utils.contains('MENDER_FEATURES_ENABLE', 'mender-uboot'    , True, False, d):
    #probably would require mender/uboot patches
    bb.fatal("mender-kernel does not currently support mender-uboot")

  elif int(d.getVar('MENDER_BOOT_PART_SIZE_MB') or 0) <= 0:
    bb.fatal("mender-kernel requires MENDER_BOOT_PART_SIZE_MB > 0")
}
addtask mender_kernel_checks before do_build
