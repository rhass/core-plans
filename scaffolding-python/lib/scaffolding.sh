#
# DO NOT OVERRIDE `do_default_xxxxx` IN PLANS!
#

#
# Internal functions. Do not use these in your plans as they can change.
#

# _example() {
#   return 127
# }

#
# Scaffolding Variables
#

scaffolding_python_pkg="core/python"

#
# Scaffolding Callback Functions
#

# The default_begin phase is executed prior to loading the scaffolding. As such
# we have a scaffolding specific callback to allow us to run anything we need
# to execute before download and build. This callback executes immediately
# after the scaffolding is loaded.
_scaffolding_begin() {
  pkg_deps=(${pkg_deps[@]} $scaffolding_python_pkg)
  pkg_env_sep=(
    ['PYTHONPATH']=':'
  )
}


# Recursively clean GOPATH and dependencies.
do_default_clean() {
  scaffolding_python_clean
}

scaffolding_python_clean() {
  pushd "$HAB_CACHE_SRC_PATH/$pkg_dirname"
  if [[ -f "setup.py" ]]; then
    python setup.py clean --all
  else
    find . \( -type f -name "*.pyc" -or -name "*.pyo" \) -delete
  fi
  popd
}

scaffolding_python_build() {
  python setup.py build
}

scaffolding_python_pip_install() {
  local name
  local version
  name="$1"
  version="$2"

  pip install \
    "$name==$version" \
    --prefix="$pkg_prefix" \
    --ignore-installed

  add_path_env 'PYTHONPATH' "$pkg_prefix"
}

scaffolding_python_install() {
  if [[ -f "$HAB_CACHE_SRC_PATH/${pkg_dirname}/setup.py" ]]; then
    python setup.py install \
      --prefix="$pkg_prefix" \
      --old-and-unmanageable || \
    python setup.py install \
      --prefix="$pkg_prefix"

    add_path_env 'PYTHONPATH' "$pkg_prefix"
  fi
}

scaffolding_python_strip() {
 do_default_strip
 scaffolding_python_clean

 # Remove tests from packages.
 find "$pkg_prefix" \
   \( -type d -name test -o -name tests \) \
   -exec rm -rf '{}' +
}

do_default_build() {
  scaffolding_python_build
}

do_default_install() {
  scaffolding_python_install
}

do_strip() {
  scaffolding_python_strip
}
