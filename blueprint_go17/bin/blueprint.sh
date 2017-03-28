#
# DO NOT OVERRIDE `do_default_xxxxx` IN PLANS!
#

#
# Internal functions. Do not use these in your plans as they can change.
#

# This strips URI prefixes from strings passed into the function. This is
# required for `go get` to function since it does not support URI.
_sanitize_pkg_source() {
  local uri
  local scheme
  uri="$1"
  scheme="$(echo "$uri" | grep :// | sed -e's%^\(.*://\).*%\1%g')"
  printf "%s" "${uri/$scheme/}"
}

#
# Blueprint Variables
#

# Path constuctor for GOPATH
export blueprint_go_gopath=${blueprint_go_gopath:-"$HAB_CACHE_SRC_PATH/$pkg_dirname"}
# Set GOPATH
export GOPATH="$blueprint_go_gopath"
# Path string used by go get without preceeding URI notation.
export blueprint_go_src_path="${GOPATH:?}/src/$(_sanitize_pkg_source "$pkg_source")"

#
# Blueprint Callback Functions
#

# The default_begin phase is executed prior to loading the blueprint. As such
# we have a blueprint specific callback to allow us to run anything we need
# to execute before download and build. This callback executes immediately
# while the blueprint is being sourced/loaded.
blueprint_go_begin() {
  return 0
}

blueprint_go_get() {
  local deps
  deps=($pkg_source ${blueprint_go_build_deps[@]})
  build_line "Running go get"
  if [[ "${#deps[@]}" -gt 0 ]] ; then
    for dependency in "${deps[@]}" ; do
      go get "$(_sanitize_pkg_source "$dependency")"
    done
  fi
}

# Fetch golang specific build dependencies.
blueprint_go_download() {
  blueprint_go_get
}

# Recursively clean GOPATH and dependencies.
do_default_clean() {
  local clean_args
  clean_args="-r -i"
  if [[ -n "$DEBUG" ]]; then
    clean_args="$clean_args -x"
  fi

  build_line "Clean the cache"

  pushd "$blueprint_go_src_path"
  go clean $clean_args
  popd
}

# Assume a automake/autoconf build script if the go project uses one.
# Otherwise, attempt to just run go build.
blueprint_go_build() {
  export PATH="$PATH:$GOPATH/bin"

  pushd "${GOPATH:?}/src/$(_sanitize_pkg_source "$pkg_source")"
  if [[ -f "$blueprint_go_src_path/Makefile" ]]; then
    make
  else
    go build
  fi
  popd
}

blueprint_go_install() {
  cp -r "${blueprint_go_gopath:?}/bin" "${pkg_prefix}/${bin}"
}


blueprint_go_begin

do_default_download() {
  blueprint_go_download
}

do_default_verify() {
  return 0
}

do_default_unpack() {
  return 0
}

do_default_build() {
  blueprint_go_build
}

do_default_install() {
  blueprint_go_install
}
