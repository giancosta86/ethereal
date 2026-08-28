use ./sdkman/hooks
use ./sdkman/paths
use ./sdkman/wrapper

var sdkman~ = $wrapper:sdkman~

var register-chdir-hooks~ = $hooks:register-chdir-hooks~

var get-sdk-directory~ = $paths:get-sdk-directory~