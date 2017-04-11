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
}
