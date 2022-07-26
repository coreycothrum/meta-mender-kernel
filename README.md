# meta-mender-kernel
Separate A/B kernel partitions for [meta-mender](https://github.com/mendersoftware/meta-mender).

Probably not very useful by itself, but is a prerequisite for things like [encrypting the rootfs](https://github.com/coreycothrum/meta-mender-luks).

## Overview
* Two additional A/B kernel partitions are created after the ``/data`` partition via the ``mender-core`` variable ``MENDER_EXTRA_PARTS``.
* On boot, GRUB selects the corresponding kernel partition based on ``mender_boot_part``. The kernel and/or initramfs are loaded from this partition.
* An ``ArtifactInstall`` state-script updates the kernel partition.
* Optional [UEFI Secure Boot](#uefi-secure-boot-integration).

### UEFI Secure Boot Integration
Requires [meta-secure-core](https://github.com/jiazhang0/meta-secure-core). See [this kas file](kas/kas.efi-secure-boot.yml) for more setup details.

There were a few gotchas integrating secure boot

[SELoader](https://github.com/jiazhang0/SELoader) is not setup to verify anything outside the ``/efi`` partition. To workaround this:
1. use ``SELoader`` to verify everything on ``/efi`` (config, env, EFI binaries, etc). This is noop and standard ``meta-efi-secure-boot`` operation.
1. use ``shim`` to verify the ``INITRAMFS_IMAGE_BUNDLE``
    1. enforce ``INITRAMFS_IMAGE_BUNDLE``
    1. sign ``INITRAMFS_IMAGE_BUNDLE`` with ``sb_sign`` to use ``MOK`` key(s)
    1. use ``chainloader`` instead of ``linux`` grub command to launch ``INITRAMFS_IMAGE_BUNDLE``

## Dependencies
This layer depends on:

    URI: git://git.openembedded.org/bitbake

    URI: git://git.openembedded.org/openembedded-core
    layers: meta
    branch: master

    URI: https://github.com/mendersoftware/meta-mender.git
    layers: meta-mender-core
    branch: master

    URI: https://github.com/coreycothrum/meta-bitbake-variable-substitution.git
    layers: meta-bitbake-variable-substitution
    branch: master

## Installation
### Add Layer to Build
In order to use this layer, the build system must be aware of it.

Assuming this layer exists at the top-level of the yocto build tree; add the location of this layer to ``bblayers.conf``, along with any additional layers needed:

    BBLAYERS ?= "                                       \
      /path/to/yocto/meta                               \
      /path/to/yocto/meta-poky                          \
      /path/to/yocto/meta-yocto-bsp                     \
      /path/to/yocto/meta-mender/meta-mender-core       \
      /path/to/yocto/meta-bitbake-variable-substitution \
      /path/to/yocto/meta-mender-kernel                 \
      "

Alternatively, run bitbake-layers to add:

    $ bitbake-layers add-layer /path/to/yocto/meta-mender-kernel

### Configure Layer
The following definitions should be added to ``local.conf`` or ``custom_machine.conf``:

    require conf/include/mender-kernel.inc

    # size (MB) of each kernel partition
    # ideally this should be in a custom machine.conf with the rest of the MENDER size params
    MENDER/KERNEL_PART_SIZE_MB = "256"

The following should be added to the image recipe (e.g. ``core-image-minimal.bbappend``):

    require conf/include/mender-kernel-image.inc

#### kas
Alternatively, a [kas](https://github.com/siemens/kas) file has been provided to help with setup/config. [Include](https://kas.readthedocs.io/en/latest/userguide.html#including-configuration-files-from-other-repos) `kas/kas.yml` from this layer in the top level kas file:

    header:
      version : 1
      includes:
        - repo: meta-mender-kernel
          file: kas/kas.yml

    local_conf_header:
      01_meta-mender-kernel: |
        # define here, or in a machine.conf file
        MENDER/KERNEL_PART_SIZE_MB = "256"

Additional files in [kas/](kas/) have been provided to selectively turn on some features, such as [UEFI Secure Boot](#uefi-secure-boot-integration).

## Building
A [standalone reference](kas/reference_builds/kas.min.x86-64.yml) build kas file has been provided.

Refer to [meta-mender-luks](https://github.com/coreycothrum/meta-mender-luks) for a more detailed build example.

### Docker
All testing has been done with the `Dockerfile` located in [this repo](https://github.com/coreycothrum/yocto-builder-docker).

### Example/Reference Build
Commands executed from [docker image](https://github.com/coreycothrum/meta-mender-luks#docker):

    # clone repo
    cd $YOCTO_WORKDIR && git clone https://github.com/coreycothrum/meta-mender-kernel.git

    # build TARGET image
    cd $YOCTO_WORKDIR && kas build $YOCTO_WORKDIR/meta-mender-kernel/kas/reference_builds/kas.min.x86-64.yml

    # build QEMU image
    cd $YOCTO_WORKDIR && kas build $YOCTO_WORKDIR/meta-mender-kernel/kas/reference_builds/kas.min.x86-64.yml:$YOCTO_WORKDIR/meta-mender-kernel/kas/reference_builds/kas.qemu.yml

## Contributing
Please submit any patches against this layer via pull request.

Commits must be signed off.

Use [conventional commits](https://www.conventionalcommits.org/).
