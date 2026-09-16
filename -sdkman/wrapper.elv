use os
use str
use ../command
use ../curl
use ../map
use ./paths

pragma unknown-command = disallow

var -bash~ = (external bash)

var -curl~ = (external curl)

fn -ensure-installed {
  if (os:is-dir $paths:sdkman-home) {
    return
  }

  echo 📥 Installing SDKMAN...

  -curl -s 'https://get.sdkman.io' |
    -bash

  echo ✅ SDKMAN installed!
}

fn -run-sdkman { |@arguments|
  curl:with-silence {
    -ensure-installed

    str:join ' ' $arguments |
      put 'source '$paths:init-script' && sdk '(all) |
      command:update-env-via-bash [SDKMAN_ENV]
  }
}

#
# Runs SDKMAN's Bash script, forwarding the arguments.
#
# If SDKMAN is not already on the system, it will be automatically installed.
#
# As a plus, ensures that the PATH and *_HOME variables are set in a robust and consistent way.
#
var sdk~ = (
  var overriding-versions = [&]

  fn handle-path-altering-command { |block|
    $block

    paths:reset-vars &overriding-versions=$overriding-versions
  }

  fn handle-use { |candidate version|
    handle-path-altering-command {
      set overriding-versions = (
        assoc $overriding-versions $candidate $version
      )
    }
  }

  fn handle-env-load {
    handle-path-altering-command {
      set overriding-versions = (
        {
          put $overriding-versions
          paths:get-sdkfile-candidates
        } |
          map:merge
      )
    }
  }

  fn handle-env-clear {
    handle-path-altering-command {
      set overriding-versions = [&]
    }
  }

  fn handle-install {
    handle-path-altering-command { }
  }

  fn handle-uninstall {
    handle-path-altering-command { }
  }

  fn process-successful-run { |@arguments|
    var argument-count = (count $arguments)

    if (== $argument-count 0) {
      return
    }

    var command = $arguments[0]

    if (has-value [use u] $command) {
      handle-use $arguments[1] $arguments[2]
    } elif (eq $command env) {
      if (== $argument-count 1) {
        handle-env-load
      } else {
        var sub-command = $arguments[1]

        if (eq $sub-command install) {
          handle-env-load
        } elif (eq $sub-command clear) {
          handle-env-clear
        }
      }
    } elif (has-value [install i] $command) {
      handle-install
    } elif (has-value [uninstall rm] $command) {
      handle-uninstall
    }
  }

  put { |@arguments|
    try {
      -run-sdkman $@arguments
    } catch {
      # Just do nothing
    } else {
      process-successful-run $@arguments
    }
  }
)