use ./-sdkman/chdir-hooks
use ./-sdkman/paths
use ./-sdkman/wrapper

var sdk-file = $paths:sdk-file

var get-candidate-dir~ = $paths:get-candidate-dir~

fn get-sdk-directory { |candidate version|
  deprecate 'Please, call `get-candidate-dir` instead!'

  get-candidate-dir $candidate &version=$version
}

var each-candidate~ = $paths:each-candidate~

var get-candidate-home-var~ = $paths:get-candidate-home-var~

var get-sdkfile-candidates~ = $paths:get-sdkfile-candidates~

var reset-vars~ = $paths:reset-vars~

fn setup-sdk-homes {
  deprecate 'Please, call `reset-vars` instead!'
  reset-vars
}

fn setup-jvm-homes {
  deprecate 'Please, call `reset-vars` instead!'
  reset-vars
}

var sdk~ = $wrapper:sdk~

fn sdkman { |@arguments|
  deprecate 'Please, call `sdk` instead!'

  sdk $@arguments
}

var register-chdir-hooks~ = $chdir-hooks:register~

var setup-env~ = $chdir-hooks:setup-env~