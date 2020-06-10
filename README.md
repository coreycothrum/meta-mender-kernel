# meta-mender-kernel

Add support for separate A/B kernel partitions to meta-mender-core.

Probably not very useful by itself, but is a prerequisite for things like [encrypting the rootfs](https://github.com/coreycothrum/meta-mender-luks).

## Brief Description

* Two additional A/B kernel partitions are created after the ``data`` partition via the ``mender-core`` variable ``MENDER_EXTRA_PARTS``.
* On boot, GRUB selects the corresponding kernel partition based on ``mender_boot_part``. The kernel and/or initramfs are loaded from this partition.
* An ``ArtifactInstall`` state-script updates the kernel partition.

## Dependencies

This layer depends on:

    URI: git://git.openembedded.org/bitbake

    URI: git://git.openembedded.org/openembedded-core
    layers: meta
    branch: master
  
    URI: https://github.com/mendersoftware/meta-mender.git
    layers: meta-mender-core
    branch: master

## Contributing

Please submit any patches against this layer via pull request. 

Commits must be signed off. 

Use good commit messages.

## Installation
### Add Layer to Build
In order to use this layer, the build system must be aware of it.

Assuming this layer exists at the top-level of the yocto build tree; add the location of this layer to ``bblayers.conf``, along with any additional layers needed:

    BBLAYERS ?= "\
      /path/to/yocto/meta \
      /path/to/yocto/meta-poky \
      /path/to/yocto/meta-yocto-bsp \
      /path/to/yocto/meta-mender/meta-mender-core \
      /path/to/yocto/meta-mender-kernel \
      "

Alternatively, run bitbake-layers to add:

    $ bitbake-layers add-layer /path/to/yocto/meta-mender-kernel

### Configure Layer
This layer should be configured with the following definitions
in ``local.conf``

    IMAGE_INSTALL += "packagegroup-mender-kernel"

    #size (MB) of each kernel partition
    MENDER/KERNEL_PART_SIZE_MB = "128"
