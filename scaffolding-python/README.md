# Python Scaffolding

## Getting Started with Scaffolding
See https://www.habitat.sh/docs/concepts-scaffolding/ to learn how to get started with Scaffolding.

## Variables
| Variable | Type | Value | Default |
| -------- | ---- | ----- | ------- |
|`scaffolding_python_pkg`| **String** | (Optional) Origin and Package Name for Python | `"core/python"` |

## Callbacks
### Scaffolding
#### scaffolding_python_clean
Performs `go clean -r -i` to recursively clean build and build deps.
#### scaffolding_python_build
This will attempt to use a `Makefile` if one is found and assumes there is a default make target. If no `Makefile` is found, `go build` is executed against the project.
#### scaffolding_python_install
Installs the application and runtime deps into `"${pkg_prefix}/${bin}"`

### Default Overrides
The following default callbacks have overrides:
* `do_default_download`Calls [scaffolding_python_download](#scaffolding_python_download)
* `do_default_clean` - Calls [scaffolding_python_clean](#scaffolding_python_clean)
* `do_default_verify` - NOP -- Returns 0
* `do_default_unpack` - NOP -- Returns 0
* `do_default_build`- Calls [scaffolding_python_build](#scaffolding_python_build)
* `do_default_install` - Calls [scaffolding_python_install](#scaffolding_python_install)
