use os
use path
use ../elvish/chdir-hooks
use ./paths
use ./wrapper

pragma unknown-command = disallow

fn -before-cd { |next-dir|
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
    wrapper:sdk env clear
  }
}

fn -after-cd {
  var current-dir-has-sdk-file = (
    path:join $pwd $paths:sdk-file |
      os:is-regular (all)
  )

  if $current-dir-has-sdk-file {
    wrapper:sdk env install
  }
}

#
# Initializes the environment variables, registers the chdir hooks for SDKMAN,
# then runs the after-cd hook.
#
fn register {
  paths:reset-vars

  chdir-hooks:register [
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