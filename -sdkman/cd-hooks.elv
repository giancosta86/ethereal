use os
use path
use ../elvish/cd-hooks
use ../fs
use ./paths
use ./wrapper

pragma unknown-command = disallow

fn -before-cd { |target-dir|
  var actual-sdk-file = (
    fs:find-in-ancestors $pwd $paths:sdk-file
  )

  var should-clear-env = (
    if $actual-sdk-file {
      var target-sdk-file = (
        fs:find-in-ancestors $target-dir $paths:sdk-file
      )

      not-eq $actual-sdk-file $target-sdk-file
    } else {
      put $false
    }
  )

  if $should-clear-env {
    wrapper:sdk env clear
  }
}

fn -after-cd {
  var sdk-file-in-pwd-existed = (
    os:is-regular $paths:sdk-file
  )

  defer {
    if (not $sdk-file-in-pwd-existed) {
      os:remove-all $paths:sdk-file
    }
  }

  if (not $sdk-file-in-pwd-existed) {
    var actual-sdk-file = (
      fs:find-in-ancestors (path:dir .) $paths:sdk-file
    )

    if $actual-sdk-file {
      fs:copy $actual-sdk-file .
    }
  }

  if (os:is-regular $paths:sdk-file) {
    wrapper:sdk env install
  }
}

#
# Initializes the environment variables, registers the chdir hooks for SDKMAN,
# then runs the after-cd hook.
#
fn register {
  paths:reset-vars

  cd-hooks:register [
    &before=$-before-cd~

    &after=$-after-cd~
  ]
}

#
# Initializes the environment variables and invokes the after-cd hook without registering it.
#
# Especially suitable for CI/CD contexts.
#
fn setup-env {
  paths:reset-vars

  -after-cd
}