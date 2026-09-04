use path
use str

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
# Given a candidate, returns the name of the related *_HOME environment variable.
#
fn get-candidate-home-var { |candidate|
  put (str:to-upper $candidate)'_HOME'
}

#
# Defines a *_HOME variable for each SDK candidate found in the PATH.
#
fn setup-sdk-homes {
  put $sdkman-home/candidates/*[nomatch-ok][type:dir] | each { |candidate-root|
    all $paths | each { |current-path|
      if (str:has-prefix $current-path $candidate-root) {
        var home-path = (path:dir $current-path)

        var candidate = (path:base $candidate-root)

        get-candidate-home-var $candidate |
          set-env (all) $home-path
      }
    }
  }
}
