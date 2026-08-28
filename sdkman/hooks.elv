use os
use path
use ./paths
use ./wrapper

fn -before-chdir-hook { |next-dir|
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
    wrapper:sdkman env clear
  }
}

fn -after-chdir-hook { |_|
  var current-dir-has-sdk-file = (
    path:join $pwd $paths:sdk-file |
      os:is-regular (all)
  )

  if $current-dir-has-sdk-file {
    wrapper:sdkman env install
  }
}

fn register-chdir-hooks {
  set before-chdir = (conj $before-chdir $-before-chdir-hook~)

  set after-chdir = (conj $after-chdir $-after-chdir-hook~)

  -after-chdir-hook $pwd
}