#!/bin/sh

set -e

function log {
  echo "$@" >&2
}
log "$(cat /etc/mender/artifact_info): $(basename "$0") was called!"

function fatal {
  log $@
  cleanup
  exit 1
}

function cleanup {
  sync

  if mount | grep -q $ROOT_MNT_DIR; then
    umount           $ROOT_MNT_DIR
  fi
  rm -fr             $ROOT_MNT_DIR

  if mount | grep -q $KERN_MNT_DIR; then
    umount           $KERN_MNT_DIR
  fi
  rm -fr             $KERN_MNT_DIR
}
trap cleanup EXIT

################################################################################
KERN_SRC_DIR="$(dirname @@MENDER_BOOT_PART_MOUNT_LOCATION@@)"

BOOT_PART="$(fw_printenv mender_boot_part | sed 's/[^=]*=//')"
KERN_PART=""
ROOT_PART=""

KERN_MNT_DIR="/tmp/kern_candidate"
ROOT_MNT_DIR="/tmp/root_candidate"

#BOOT_PART :   active partition
#ROOT_PART : inactive partition
#KERN_PART : inactive partition
if   [ "$BOOT_PART" -eq "@@MENDER_ROOTFS_PART_A_NUMBER@@" ]; then
  ROOT_PART="@@MENDER_ROOTFS_PART_B_NUMBER@@"
  KERN_PART="@@MENDER/KERNEL_PART_B_NUMBER@@"
elif [ "$BOOT_PART" -eq "@@MENDER_ROOTFS_PART_B_NUMBER@@" ]; then
  ROOT_PART="@@MENDER_ROOTFS_PART_A_NUMBER@@"
  KERN_PART="@@MENDER/KERNEL_PART_A_NUMBER@@"
else
  fatal "@@MENDER_STORAGE_DEVICE_BASE@@$BOOT_PART is not a known rootfs partition"
fi

log "@@MENDER_STORAGE_DEVICE_BASE@@$BOOT_PART is the active partition"
log "@@MENDER_STORAGE_DEVICE_BASE@@$KERN_PART will be updated with new kernel candidate"

if ! mount | grep -q $ROOT_MNT_DIR; then
  mkdir -p                                                $ROOT_MNT_DIR
  mount -o ro  @@MENDER_STORAGE_DEVICE_BASE@@$ROOT_PART   $ROOT_MNT_DIR
  log "mounted @@MENDER_STORAGE_DEVICE_BASE@@$ROOT_PART @ $ROOT_MNT_DIR"
fi

if ! mount | grep -q $KERN_MNT_DIR; then
  mkdir -p                                                $KERN_MNT_DIR
  mount -o rw  @@MENDER_STORAGE_DEVICE_BASE@@$KERN_PART   $KERN_MNT_DIR
  log "mounted @@MENDER_STORAGE_DEVICE_BASE@@$KERN_PART @ $KERN_MNT_DIR"
fi

rsync -avq $ROOT_MNT_DIR/$KERN_SRC_DIR/*                  $KERN_MNT_DIR --exclude $(basename @@MENDER_BOOT_PART_MOUNT_LOCATION@@)

log "finished updating kernel partition: @@MENDER_STORAGE_DEVICE_BASE@@$KERN_PART"

cleanup

exit 0
