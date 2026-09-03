use os
use path
use str
use github.com/giancosta86/ethereal/v1/map

pragma unknown-command = disallow

var -which~ = (external which)

var sdkman-home = (path:join ~ .sdkman)

var sdkman-script = (path:join $sdkman-home bin sdkman-init.sh)

var sdk-file = .sdkmanrc

#
# Returns the absolute path of the directory containing the requested SDK.
#
fn get-sdk-directory { |candidate version|
  path:join $sdkman-home candidates $candidate $version
}

#
# Emits a map of [<candidate name> <current home path>] for the installed SDKs.
#
fn get-installed-homes {
  put $sdkman-home/candidates/*[nomatch-ok]/current |
    each { |current-home-path|
      var candidate-name = (
        path:dir $current-home-path |
          path:base (all)
      )

      put [$candidate-name $current-home-path]
    } |
      make-map
}

#
# Emits the names of the installed candidates - the ones having a "current" version.
#
fn get-installed-candidates {
  get-installed-homes |
    map:keys
}

fn -get-home-var { |candidate|
  str:to-upper $candidate |
    put (all)'_HOME'
}

#
# Defines a *_HOME variable for each candidate having a "current" version set.
#
fn setup-jvm-homes {
  get-installed-homes |
    map:iterate { |candidate home-path|
      -get-home-var $candidate |
        set-env (all) $home-path
    }
}

#
# Emits a *_HOME environment variable for each candidate having a "current" version set.
#
fn get-jvm-home {
  get-installed-homes |
    map:keys |
    each $-get-home-var~
}