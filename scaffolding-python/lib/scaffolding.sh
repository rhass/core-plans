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

# This variable allows a user to set the habitat package name to be different
# from the package name on pypi if needed.
pkg_scaffolding_python_pip_name="${pkg_scaffolding_python_pip_name:-$pkg_name}"
# Name of python package to add to the build and runtime deps.
scaffolding_python_pkg="core/python"
# Initialize this variable for later use. While you can set this directly in
# your plan, in most cases you shouldn't need to do so.
scaffolding_python_pip_only=""

#
# Scaffolding Callback Functions
#

# Helper function to check for a setup.py file.
_setup_py_exists() {
  [[ -f "$HAB_CACHE_SRC_PATH/$pkg_dirname/setup.py" ]]
}

# Helper function to disable default phases which are not used for pip installs.
_pip_install_only() {
  scaffolding_python_pip_only="true"

  do_download() {
    return 0
  }

  do_verify() {
    return 0
  }

  do_unpack() {
    return 0
  }
}

# The default_begin phase is executed prior to loading the scaffolding. As such
# we have a scaffolding specific callback to allow us to run anything we need
# to execute before download and build. This callback executes immediately
# after the scaffolding is loaded.
_scaffolding_begin() {
  pkg_deps=(${pkg_deps[@]} $scaffolding_python_pkg)
  pkg_build_deps=(${pkg_build_deps[@]} $scaffolding_python_pkg)
  pkg_env_sep=(
    ['PYTHONPATH']=':'
  )
  # Disable download, verify, and unpack if we are only installing via pip.
  # It should be noted that we currently must have `pkg_source` since we
  # validate plans before scaffolding is loaded.
  if [[ "$pkg_source" == "pip" ]] || [[ "$pkg_source" =~ ^nosuchfile.* ]] ; then
    _pip_install_only
  fi
}

# Removes bytecode and other stuff we do not need to package up.
scaffolding_python_clean() {
  if [[ $(_setup_py_exists) ]]; then
    pushd "$HAB_CACHE_SRC_PATH/$pkg_dirname" >/dev/null
    python setup.py clean --all
    popd >/dev/null
  else
    find "$HAB_CACHE_SRC_PATH/$pkg_dirname" \( -type f -name "*.pyc" -or -name "*.pyo" \) -delete
  fi
}

# Run setup.py if it exists, otherwise return so pip can do the install.
scaffolding_python_build() {
  if [[ $(_setup_py_exists) ]]; then
    build_line "Running setup.py"
    python setup.py build
  else
    return 0
  fi
}

# This can be called directly to install multiple pip packages.
# Usage: `scaffolding_python_pip_install "mypackage "myversion"`
# OR `scaffolding_python_pip_install "mypackage" "myversion" "--other-pip-arg"`
scaffolding_python_pip_install() {
  local name
  local version
  local args
  name="$1"
  version="$2"
  args="${3:-"$name==$version --prefix=$pkg_prefix --force-reinstall --no-compile"}"

  if [[ -n "$DEBUG" ]]; then
    args="$args -vvv"
  else
    args="$args --quiet"
  fi

  build_line "Running pip install"
  # Disable shellcheck rule to ensure the pip install command is expanded
  # with the correct syntax.
  # shellcheck disable=SC2086
  pip install $args
}


# Attempt to install the python package via setup.py without egg files.
# We do not need the eggs since we are already keeping everything contained
# within the hab package.
scaffolding_python_install() {
  if [[ -n "$scaffolding_python_pip_only" ]]; then
    scaffolding_python_pip_install "$pkg_scaffolding_python_pip_name" "$pkg_version"
  else
    python setup.py install \
      --prefix="$pkg_prefix" \
      --old-and-unmanageable || \
    python setup.py install \
      --prefix="$pkg_prefix"
  fi

  add_path_env 'PYTHONPATH' "$PYTHON_SITE_PACKAGES"
}

# Run do_default_strip to ensure any native C extentions are stripped.
# After this completes, we clean the bytecode since we don't need to keep it
# in the hab package and remove tests since they won't be executed at this
# stage.
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
