# meta-mender-kernel
Separate A/B kernel partitions for [meta-mender](https://github.com/mendersoftware/meta-mender).

Probably not very useful by itself, but is a prerequisite for things like [encrypting the rootfs](https://github.com/coreycothrum/meta-mender-luks).

## Overview
* Two additional A/B kernel partitions are created after the `/data` partition via the `mender-core` variable `MENDER_EXTRA_PARTS`.
* On boot, GRUB selects the corresponding kernel partition based on `mender_boot_part`. The kernel and/or initramfs are loaded from this partition.
* An `ArtifactInstall` [state-script](https://docs.mender.io/artifact-creation/state-scripts) updates the kernel partition.
* Optional [UEFI Secure Boot](#uefi-secure-boot-integration).

### UEFI Secure Boot Integration
Requires [meta-secure-core](https://github.com/jiazhang0/meta-secure-core). See [this kas file](kas/kas.efi-secure-boot.yml) for more setup details.

There were a few gotchas integrating secure boot

[SELoader](https://github.com/jiazhang0/SELoader) is not setup to verify anything outside the `/efi` partition. To workaround this:
1. use `SELoader` to verify everything on `/efi` (config, env, EFI binaries, etc). This is noop and standard `meta-efi-secure-boot` operation.
1. use `shim` to verify the `INITRAMFS_IMAGE_BUNDLE`
    1. enforce `INITRAMFS_IMAGE_BUNDLE`
    1. sign `INITRAMFS_IMAGE_BUNDLE` with `sb_sign` to use `MOK` key(s)
    1. use `chainloader` instead of `linux` grub command to launch `INITRAMFS_IMAGE_BUNDLE`

## Installation
* Add this layer to `bblayers.conf`
* `local.conf` should include: `require conf/include/mender-kernel.inc` and any [configuration variables](#Variables)
* Image recipe should include: `require conf/include/mender-kernel-image.inc`

## Configuration
### Variables
| Variable                     | Default | Description                        |
| ---                          | ---     | ---                                |
| `MENDER/KERNEL_PART_SIZE_MB` | `256`   | size (MB) of each kernel partition |

## Release Schedule and Roadmap
This layer will remain compatible with the latest [YOCTO LTS](https://wiki.yoctoproject.org/wiki/Releases). This mirrors what [meta-mender](https://github.com/mendersoftware/meta-mender) does.
