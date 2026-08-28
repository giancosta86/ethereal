use os
use str
use ../command
use ./paths

pragma unknown-command = disallow

var -bash~ = (external bash)

var -curl~ = (external curl)


fn -ensure-installed {
  if (os:is-dir $paths:sdkman-home) {
    return
  }

  echo 📥 Installing SDKMAN...

  -curl -s 'https://get.sdkman.io' | -bash

  echo ✅ SDKMAN installed!
}

fn -run-sdkman { |@arguments|
  -ensure-installed

  str:join ' ' $arguments |
    put "source '"$paths:sdkman-script"' && sdk "(all) |
    command:run-bash-and-update-path
}

#
# Runs SDKMAN's Bash script - installing it if it's not already available - forwarding the arguments.
#
fn sdkman { |@arguments|
  -run-sdkman $@arguments
}