INHERIT                       += "mender-kernel-setup"
MENDER_FEATURES_DISABLE       += "mender-growfs-data"
MENDER_FEATURES_ENABLE:append  = " mender-grub mender-image-uefi"

MACHINE_FEATURES:append        = " efi"
MACHINE_FEATURES:remove        = " pcbios"

IMAGE_INSTALL:append           = " packagegroup-mender-kernel"

# these defaults changed in meta-secure-core, setting back to old values here
UEFI_SELOADER    = "1"
GRUB_SIGN_VERIFY = "0"
