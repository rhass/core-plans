pkg_name=blueprint_go17
pkg_description="Blueprint for Go 1.7 Applications"
pkg_origin=core
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_version="0.1.0"
pkg_license=('Apache-2.0')
pkg_bindir=(bin)
pkg_source=nosuchfile.tar.gz
pkg_upstream_url="https://github.com/habitat-sh/core-plans"
pkg_deps=(
  ${pkg_deps[@]}
  core/go
  core/git
  core/gcc
  core/make
)
blueprint_go17_build_deps=()

do_install() {
  install -D -m 0644 "$PLAN_CONTEXT/bin/blueprint.sh" "$pkg_prefix/bin/blueprint.sh"
}

# Turn the remaining default phases into no-ops
do_prepare() {
  return 0
}

do_download() {
  return 0
}

do_build() {
  return 0
}

do_verify() {
  return 0
}

do_unpack() {
  return 0
}
