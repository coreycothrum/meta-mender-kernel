################################################################################
mender_kernel_delete_kernel_parts() {
  if [ ! -f "$1" ]; then
    bbfatal "mender_kernel_delete_kernel_parts()::file($1) is not valid or does not exist"
  fi

  local kernelparta="${MENDER/KERNEL_PART_A}"
  local kernelpartb="${MENDER/KERNEL_PART_B}"

  sed -i -e "\|${kernelparta}|d" \
         -e "\|${kernelpartb}|d" \
         ${1}
}

################################################################################
def mender_kernel_calc_dir_size_mb(root_path):
  size = 0

  for path, dirs, files in os.walk(root_path):
    for fname in files:
      fp = os.path.join(path, fname)

      if not os.path.islink(fp):
        size += os.path.getsize(fp)

  size_mb = size / 1e6

  import math
  return math.ceil(size_mb)
