# DO NOT OVERRIDE `do_default_xxxxx` IN PLANS!

# Blueprint Variables
blueprint_go_gopath=${blueprint_go_gopath:-"$HAB_CACHE_SRC_PATH/$pkg_dirname"}

# Internal functions. Do not use these in your plans as they can change.
_sanitize_pkg_source() {
  local uri
  local scheme
  uri="$1"
  scheme="$(echo "$uri" | grep :// | sed -e's%^\(.*://\).*%\1%g')"
  printf "%s" "${uri/$scheme/}"
}

# Blueprint Callback Functions

blueprint_go_get() {
  local deps
  deps=($pkg_source ${blueprint_go_build_deps[@]})
  if [[ "${#deps[@]}" -gt 0 ]] ; then
    for dependency in "${deps[@]}" ; do
      go get "$(_sanitize_pkg_source "$dependency")"
    done
  fi
}

# Fetch golang specific build dependencies.
blueprint_go_download() {
  # Set GOPATH
  export GOPATH="$blueprint_go_gopath"
  # Fetch dependencies
  blueprint_go_get
}

do_default_clean() {
  test -d "${blueprint_go_gopath:?}/pkg" && rm -rf "${blueprint_go_gopath:?}/pkg"
  test -d "${blueprint_go_gopath:?}/bin" && rm -rf "${blueprint_go_gopath:?}/bin"
}

# Assume a automake/autoconf build script if the go project uses one.
# Otherwise, attempt to just run go build.
blueprint_go_build() {
  local src_path
  src_path="${GOPATH:?}/src/$(_sanitize_pkg_source "$pkg_source")"
  export PATH="$PATH:$GOPATH/bin"

  pushd "${GOPATH:?}/src/$(_sanitize_pkg_source "$pkg_source")"
  if [[ -f "$src_path/Makefile" ]]; then
    make
  else
    go build
  fi
  popd
}

blueprint_go_install() {
  cp -r "${blueprint_go_gopath:?}/bin" "${pkg_prefix}/${bin}"
}

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
