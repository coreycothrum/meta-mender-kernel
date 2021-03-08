MENDER/KERNEL_PART_A_NAME                  = "kernela"
MENDER/KERNEL_PART_B_NAME                  = "kernelb"
MENDER/KERNEL_EXTRA_PARTS                  = "${MENDER/KERNEL_PART_A_NAME} ${MENDER/KERNEL_PART_B_NAME}"

MENDER_EXTRA_PARTS                        += "${MENDER/KERNEL_EXTRA_PARTS}"
MENDER_EXTRA_PARTS[kernela]                = "--label=${MENDER/KERNEL_PART_A_NAME} --source rawcopy --sourceparams=file=${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.kernelimg --fstype=${MENDER/KERNEL_PART_FSTYPE_TO_GEN}"
MENDER_EXTRA_PARTS[kernelb]                = "--label=${MENDER/KERNEL_PART_B_NAME} --source rawcopy --sourceparams=file=${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.kernelimg --fstype=${MENDER/KERNEL_PART_FSTYPE_TO_GEN}"
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
MENDER/KERNEL_PART_SIZE_MB_DEFAULT         = "256"

MENDER/KERNEL_INITRAMFS_LINK_NAME        ??= "initramfs.img"

MENDER/KERNEL_KERN_BUILD_STAGING_DIR       = "/mender-kernel/"
MENDER/KERNEL_KERN_CANDIDATE_MNT_DIR       = "/tmp/kern_candidate"
MENDER/KERNEL_ROOT_CANDIDATE_MNT_DIR       = "/tmp/root_candidate"

################################################################################
#FIXME - this should be in mender-core
MENDER_DATA_PART_MOUNT_LOCATION            = "/data"
################################################################################
