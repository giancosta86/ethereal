use os
use path
use str
use ../seq

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
# Defines a *_HOME variable for each candidate having a "current" version set.
#
fn setup-jvm-homes {
  put $sdkman-home/candidates/*[type:dir][nomatch-ok] | each { |candidate-dir|
    var current-link = (path:join $candidate-dir current)

    if (os:exists $current-link) {
      var candidate = (path:base $candidate-dir)

      var home-var = (
        str:to-upper $candidate |
          put (all)'_HOME'
      )

      set-env $home-var $current-link
    }
  }
}