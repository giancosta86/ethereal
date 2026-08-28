use ./sdkman/hooks
use ./sdkman/wrapper

var sdkman~ = $wrapper:sdkman~

var register-chdir-hooks~ = $hooks:register-chdir-hooks~

#
# Returns the absolute path of the directory containing the requested SDK.
#
fn get-sdk-directory { |candidate version|
  sdkman home $candidate $version
}
