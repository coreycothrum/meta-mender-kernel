#!/bin/sh

function log {
  echo "$@" >&2
}

function cleanup {
  sync

  mount | grep -q $KERN_MNT_DIR && umount -l $KERN_MNT_DIR
  rm -fr          $KERN_MNT_DIR

  mount | grep -q $ROOT_MNT_DIR && umount -l $ROOT_MNT_DIR
  rm -fr          $ROOT_MNT_DIR

  sync
}
trap cleanup EXIT

################################################################################
KERN_MNT_DIR="@@MENDER/KERNEL_KERN_CANDIDATE_MNT_DIR@@"
ROOT_MNT_DIR="@@MENDER/KERNEL_ROOT_CANDIDATE_MNT_DIR@@"

exit
