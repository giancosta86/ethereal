use os
use path
use str

var -sdkman-home = (path:join ~ .sdkman)

var -sdkman-script = (path:join $-sdkman-home bin sdkman-init.sh)

fn -ensure-installed {
  if (os:is-dir $-sdkman-home) {
    return
  }

  echo 📥 Installing SDKMAN...

  curl -s 'https://get.sdkman.io' | bash

  echo ✅ SDKMAN installed!
}

#
# Returns the absolute path of the directory containing the requested SDK.
#
fn get-sdk-directory { |candidate version|
  path:join $-sdkman-home candidates $candidate $version
}

#
# Runs SDKMAN's Bash script, forwarding the arguments.
#
fn sdkman { |@arguments|
  -ensure-installed

  str:join ' ' $arguments |
    bash -c "source '"$-sdkman-script"'; sdk "(all)
}
