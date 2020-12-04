#!/bin/sh
################################################################################
PATH=$PATH:/sbin:/bin:/usr/sbin:/usr/bin

mkdir -p /proc ; mount -n -t proc     proc     /proc
mkdir -p /sys  ; mount -n -t sysfs    sysfs    /sys
mkdir -p /dev  ; mount -n -t devtmpfs devtmpfs /dev
mkdir -p /run  ; mount -n -t tmpfs    tmpfs    /run

mknod /dev/console c 5 1
mknod /dev/null    c 1 3
mknod /dev/zero    c 1 5

################################################################################
CONSOLE="/dev/console"

MNT_DIR="/tmp"

ROOT_MNT="$MNT_DIR/root"
ROOT_DEV=""

BOOT_MNT="$MNT_DIR@@MENDER_BOOT_PART_MOUNT_LOCATION@@"
BOOT_DEV=@@MENDER_BOOT_PART@@

DATA_MNT="$MNT_DIR@@MENDER_DATA_PART_MOUNT_LOCATION@@"
DATA_DEV=@@MENDER_DATA_PART@@

################################################################################
read_args() {
  [ -z "${CMDLINE+x}" ] && CMDLINE=`cat /proc/cmdline`
  for arg in $CMDLINE; do
    optarg=`expr "x$arg" : 'x[^=]*=\(.*\)' || echo ''`
    case $arg in
      root=*)
        ROOT_DEV=$optarg ;;
    esac
  done
}

################################################################################
read_args

mkdir  -p           $BOOT_MNT
mount     $BOOT_DEV $BOOT_MNT

mkdir  -p           $ROOT_MNT
mount     $ROOT_DEV $ROOT_MNT

cd                  $ROOT_MNT
exec switch_root    $ROOT_MNT /sbin/init
