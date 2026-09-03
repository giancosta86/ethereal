use ./-sdkman/hooks
use ./-sdkman/paths
use ./-sdkman/wrapper

var sdk-file = $paths:sdk-file

var sdk~ = $wrapper:sdk~

var register-chdir-hooks~ = $hooks:register-chdir-hooks~

var get-sdk-directory~ = $paths:get-sdk-directory~

var setup-jvm-homes~ = $paths:setup-jvm-homes~

var setup-env~ = $hooks:setup-env~

fn sdkman { |@arguments|
  deprecate 'Please, call `sdk` instead'

  sdk $@arguments
}
