#!/bin/sh
set -e

function log {
  echo "$@" >&2
}
log "$(cat /etc/mender/artifact_info): $(basename "$0") was called!"

function fatal {
  log $@
  exit 1
}

function cleanup {
  sync
}
trap cleanup EXIT

################################################################################
KERN_SRC_DIR="$(dirname @@MENDER_BOOT_PART_MOUNT_LOCATION@@)"

if ! command -v fw_printenv &> /dev/null; then
  alias fw_printenv='grub-mender-grubenv-print'
fi

UPGRADE_AV="$(fw_printenv upgrade_available | sed 's/[^=]*=//')"
BOOT_COUNT="$(fw_printenv bootcount         | sed 's/[^=]*=//')"
BOOT_PART="$(fw_printenv  mender_boot_part  | sed 's/[^=]*=//')"
KERN_PART=""
ROOT_PART=""

KERN_MNT_DIR="@@MENDER/KERNEL_KERN_CANDIDATE_MNT_DIR@@"
ROOT_MNT_DIR="@@MENDER/KERNEL_ROOT_CANDIDATE_MNT_DIR@@"

#BOOT_PART :   active partition
#ROOT_PART : inactive partition
#KERN_PART : inactive partition
if   [ "$BOOT_PART" -eq "@@MENDER_ROOTFS_PART_A_NUMBER@@" ] && [ "$UPGRADE_AV" -ne "0" ]; then
  # an update has already happened, but the system hasn't restarted. mender is now overwriting it.
  # don't need to invert the reported mender_boot_part
  ROOT_PART="@@MENDER_ROOTFS_PART_A_NUMBER@@"
  KERN_PART="@@MENDER/KERNEL_PART_A_NUMBER@@"

elif [ "$BOOT_PART" -eq "@@MENDER_ROOTFS_PART_A_NUMBER@@" ]; then
  # invert mender_boot_part to mount the update candidate partitions
  ROOT_PART="@@MENDER_ROOTFS_PART_B_NUMBER@@"
  KERN_PART="@@MENDER/KERNEL_PART_B_NUMBER@@"

elif [ "$BOOT_PART" -eq "@@MENDER_ROOTFS_PART_B_NUMBER@@" ] && [ "$UPGRADE_AV" -ne "0" ]; then
  # an update has already happened, but the system hasn't restarted. mender is now overwriting it.
  # don't need to invert the reported mender_boot_part
  ROOT_PART="@@MENDER_ROOTFS_PART_B_NUMBER@@"
  KERN_PART="@@MENDER/KERNEL_PART_B_NUMBER@@"

elif [ "$BOOT_PART" -eq "@@MENDER_ROOTFS_PART_B_NUMBER@@" ]; then
  # invert mender_boot_part to mount the update candidate partitions
  ROOT_PART="@@MENDER_ROOTFS_PART_A_NUMBER@@"
  KERN_PART="@@MENDER/KERNEL_PART_A_NUMBER@@"

else
  fatal "@@MENDER_STORAGE_DEVICE_BASE@@$BOOT_PART is not a known rootfs partition"

fi

log "updating @@MENDER_STORAGE_DEVICE_BASE@@$KERN_PART with new kernel candidate from @@MENDER_STORAGE_DEVICE_BASE@@$ROOT_PART"

if ! mount |                                      grep -q $ROOT_MNT_DIR; then
  mkdir -p                                                $ROOT_MNT_DIR
  mount -o ro  @@MENDER_STORAGE_DEVICE_BASE@@$ROOT_PART   $ROOT_MNT_DIR
  log "mounted @@MENDER_STORAGE_DEVICE_BASE@@$ROOT_PART @ $ROOT_MNT_DIR"
fi

if ! mount |                                      grep -q $KERN_MNT_DIR; then
  mkdir -p                                                $KERN_MNT_DIR
  mount -o rw  @@MENDER_STORAGE_DEVICE_BASE@@$KERN_PART   $KERN_MNT_DIR
  log "mounted @@MENDER_STORAGE_DEVICE_BASE@@$KERN_PART @ $KERN_MNT_DIR"
fi

rsync -avqI $ROOT_MNT_DIR/$KERN_SRC_DIR/*                 $KERN_MNT_DIR --exclude $(basename @@MENDER_BOOT_PART_MOUNT_LOCATION@@)

log "finished updating kernel partition: @@MENDER_STORAGE_DEVICE_BASE@@$KERN_PART"

exit
