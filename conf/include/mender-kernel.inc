IMAGE_INSTALL_append    += "packagegroup-mender-kernel"
INHERIT                 += "mender-kernel-setup"

MACHINE_FEATURES_remove += "pcbios"
MACHINE_FEATURES_append += "efi"

MENDER_FEATURES_DISABLE += "mender-growfs-data"
