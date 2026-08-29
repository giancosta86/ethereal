use path

pragma unknown-command = disallow

var sdkman-home = (path:join ~ .sdkman)

var sdkman-script = (path:join $sdkman-home bin sdkman-init.sh)

var sdk-file = .sdkmanrc

#
# Returns the absolute path of the directory containing the requested SDK.
#
fn get-sdk-directory { |candidate version|
  path:join $sdkman-home candidates $candidate $version
}
