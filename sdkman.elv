use ./-sdkman/hooks
use ./-sdkman/paths
use ./-sdkman/wrapper

var sdk-file = $paths:sdk-file

var sdk~ = $wrapper:sdk~

var register-chdir-hooks~ = $hooks:register-chdir-hooks~

var get-sdk-directory~ = $paths:get-sdk-directory~

var setup-jvm-homes~ = $paths:setup-jvm-homes~

fn sdkman { |@arguments|
  deprecate 'Please, use `sdk` instead'

  sdk $@arguments
}