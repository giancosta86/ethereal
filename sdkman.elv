use ./-sdkman/hooks
use ./-sdkman/paths
use ./-sdkman/wrapper

var sdk-file = $paths:sdk-file

var sdk~ = $wrapper:sdk~

var register-chdir-hooks~ = $hooks:register-chdir-hooks~

var get-sdk-directory~ = $paths:get-sdk-directory~

var get-candidate-home-var~ = $paths:get-candidate-home-var~

var setup-sdk-homes~ = $paths:setup-sdk-homes~

fn setup-jvm-homes {
  deprecate 'Use setup-sdk-homes instead'
  setup-sdk-homes
}

var setup-env~ = $hooks:setup-env~

fn sdkman { |@arguments|
  deprecate 'Please, call `sdk` instead'

  sdk $@arguments
}

var get-sdkfile-candidates~ = $paths:get-sdkfile-candidates~