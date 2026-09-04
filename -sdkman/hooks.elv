use os
use path
use ./paths
use ./wrapper

pragma unknown-command = disallow

var -latest-dir = $nil

fn -before-chdir-hook { |next-dir|
  if (eq $next-dir $-latest-dir) {
    return
  }

  var current-dir-has-sdk-file = (
    path:join $pwd $paths:sdk-file |
      os:is-regular (all)
  )

  var next-dir-has-sdk-file = (
    path:join $next-dir $paths:sdk-file |
      os:is-regular (all)
  )

  if (
    and $current-dir-has-sdk-file (not $next-dir-has-sdk-file)
  ) {
    try {
      wrapper:sdk env clear
    } catch {
      # Just do nothing
    }
  }
}

fn -run-sdkman-to-update-path {
  wrapper:sdk version > $os:dev-null 2>&1
}

fn -after-chdir-hook { |_|
  if (eq $pwd $-latest-dir) {
    return
  }

  set -latest-dir = $pwd

  var current-dir-has-sdk-file = (
    path:join $pwd $paths:sdk-file |
      os:is-regular (all)
  )

  if $current-dir-has-sdk-file {
    try {
      wrapper:sdk env install
      wrapper:sdk env use
    } catch {
      # Just do nothing
    }
  }

  paths:setup-sdk-homes
}

#
# Ensures that SDKMAN's paths are included into the PATH environment variable,
# then runs the post-cd hook on the current directory.
#
fn setup-env {
  -run-sdkman-to-update-path

  -after-chdir-hook $pwd
}

fn register-chdir-hooks {
  set before-chdir = (conj $before-chdir $-before-chdir-hook~)

  set after-chdir = (conj $after-chdir $-after-chdir-hook~)

  setup-env
}