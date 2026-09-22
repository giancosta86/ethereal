pragma unknown-command = disallow

var -pipx~ = (external pipx)

#
# Emits the qualified package string, according to the given version:
#
# * <package>==<version>, if <version> is passed
#
# * just <package> otherwise.
#
fn qualify { |package &version=$nil|
  var version-suffix = (
    if $version {
      put '=='$version
    } else {
      put ''
    }
  )

  put $package''$version-suffix
}

fn -is-installed {
  has-external pipx
}

fn -install {
  echo 📥 Installing pipx...

  (external python3) -m pip install pipx

  echo 🚀 pipx ready!
}

#
# Runs the `pipx` command with the given arguments - installing it via `pip` if it's not already on the system.
#
fn pipx { |@arguments|
  if (not (-is-installed)) {
    -install
  }

  -pipx $@arguments
}

#
# Utility function installing the given package at the given, optional version, using `pipx`;
# as usual in this module, if `pipx` is not already on the system, it will be installed via `pip`.
#
fn install { |package &version=$nil|
  qualify $package &version=$version |
    pipx install (all)
}

#
# Given a package and and optional version, immediately returns a wrapper that, **when called**:
#
# 1. Installs `pipx`, if it's not already on the system.
#
# 2. Calls `pipx run`, with:
#
#    * the `--quiet` flag
#
#    * the qualified <package>[==<version>] identifier
#
#    * the arguments passed to the wrapper itself.
#
fn get-command { |package &version=$nil|
  put { |@arguments|
    qualify $package &version=$version |
      pipx run --quiet (all) $@arguments
  }
}