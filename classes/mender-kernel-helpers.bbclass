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

def bitbake_variables_search_and_expand(paths, delim, d):
  if   not        d           : bb.fatal("bitbake variables (d) not provided")
  elif not        paths       : bb.fatal("no valid argument provided")
  elif isinstance(paths, list): pass
  elif isinstance(paths, str ): paths = [paths]
  else                        : bb.fatal("path(s) must be a string or list of strings")

  import filecmp
  import os
  import re
  import subprocess

  is_text = lambda filename: "text" in str(subprocess.check_output(["file", "-b", filename]))
  pattern = delim + r"(?P<vname>[^@]+?)" + delim
  regex   = re.compile(pattern)
  rtn     = "true"

  for path in (list(paths) or []):
    for root, dirs, fnames in ([(os.path.dirname(path),[],[path])] if os.path.isfile(path) else os.walk(path)):
      for file in (os.path.join(root, fname) for fname in fnames):
        if not os.path.isfile(file): continue
        if     os.path.islink(file): continue
        if not        is_text(file): continue

        try:
          file_swp = file + '.swp'
          with open(file, 'r') as fp, open(file_swp, 'w') as fp_swp:
            for line in fp:
              buf = line
              for match in regex.findall(line):
                if not d.getVar(match):
                  bb.warn('{file}: {var} is not a known bitbake variable, not expanding'.format(file=file, var=match))
                else:
                  buf = buf.replace(delim + match + delim, d.getVar(match))

              fp_swp.write(buf)

        except Exception as e:
          rtn = "false"
          raise e

        finally:
          if filecmp.cmp(file, file_swp, shallow=False):
            os.remove(file_swp)
          else:
            os.replace(file_swp, file)

  return rtn
