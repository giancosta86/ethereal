use ./-sdkman/hooks
use ./-sdkman/paths
use ./-sdkman/wrapper

var sdk~ = $wrapper:sdk~

fn sdkman { |@arguments|
  deprecate 'Please, use `sdk` instead'

  sdk $@arguments
}

var register-chdir-hooks~ = $hooks:register-chdir-hooks~

var get-sdk-directory~ = $paths:get-sdk-directory~

var setup-jvm-homes~ = $paths:setup-jvm-homes~