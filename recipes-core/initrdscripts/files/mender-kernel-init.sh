#!/usr/bin/bash
################################################################################
CONSOLE="/dev/console"
PATH=$PATH:/sbin:/bin:/usr/sbin:/usr/bin

mkdir -p /dev  ; mount -n -t devtmpfs devtmpfs /dev
mkdir -p /proc ; mount -n -t proc     proc     /proc
mkdir -p /run  ; mount -n -t tmpfs    tmpfs    /run
mkdir -p /sys  ; mount -n -t sysfs    sysfs    /sys

mknod /dev/console c 5 1
mknod /dev/null    c 1 3
mknod /dev/zero    c 1 5

ln -s /proc/self/fd /dev/fd

exec <$CONSOLE >$CONSOLE 2>$CONSOLE

################################################################################
################################################################################
################################################################################
ROOT_DEV=""
ROOT_MNT="/tmp/root"

read_args() {
  [[ -z "${CMDLINE+x}" ]] && CMDLINE=`cat /proc/cmdline`
  for arg in ${CMDLINE}; do
    optarg=`expr "x${arg}" : 'x[^=]*=\(.*\)' || echo ''`
    case ${arg} in
      root=*)
        ROOT_DEV=${optarg} ;;
    esac
  done
}

################################################################################
################################################################################
################################################################################
read_args

mkdir  -p                      @@MENDER_BOOT_PART_MOUNT_LOCATION@@
mount     @@MENDER_BOOT_PART@@ @@MENDER_BOOT_PART_MOUNT_LOCATION@@

mkdir  -p             ${ROOT_MNT}
mount     ${ROOT_DEV} ${ROOT_MNT}
cd                    ${ROOT_MNT}
exec switch_root      ${ROOT_MNT} /sbin/init

################################################################################
