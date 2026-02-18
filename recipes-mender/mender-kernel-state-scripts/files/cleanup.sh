#!/bin/sh
set -e

function log {
  echo "$@" >&2
}
log "$(mender show-artifact): $(basename "$0") was called!"

function cleanup {
  sync

  # cleanup kernel mount
  if mount | grep -q $KERN_MNT_DIR; then
    umount           $KERN_MNT_DIR
  fi
  rm -fr             $KERN_MNT_DIR

  # cleanup rootfs mount
  if mount | grep -q $ROOT_MNT_DIR; then
    umount           $ROOT_MNT_DIR
  fi
  rm -fr             $ROOT_MNT_DIR

  sync
}
trap cleanup EXIT

################################################################################
KERN_MNT_DIR="@@MENDER/KERNEL_KERN_CANDIDATE_MNT_DIR@@"
ROOT_MNT_DIR="@@MENDER/KERNEL_ROOT_CANDIDATE_MNT_DIR@@"

exit
