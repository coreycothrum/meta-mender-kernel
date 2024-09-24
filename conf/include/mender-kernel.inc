INHERIT                 += "mender-kernel-setup"
MENDER_FEATURES_DISABLE += "mender-growfs-data"

IMAGE_INSTALL:append     = " packagegroup-mender-kernel"

MACHINE_FEATURES:remove  = " pcbios"
MACHINE_FEATURES:append  = " efi"

PREFERRED_PROVIDER_mender-native  = "mender-client-native"
PREFERRED_RPROVIDER_mender-auth   = "mender-client"
PREFERRED_RPROVIDER_mender-update = "mender-client"
