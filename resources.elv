use path
use ./lang

pragma unknown-command = disallow

#
# Takes, as a single input, the output of the `src` command for the calling module.
#
# Returns an object with a `get-path` method, taking as input a resource path relative
# to the calling module, and returning the absolute path of such resource.
#
fn for-script { |@arguments|
  var caller-src-result = (lang:get-single-input $arguments)

  var caller-path = $caller-src-result[name]
  var caller-dir = (path:dir $caller-path)

  put [
    &get-path={ |@arguments|
      var relative-path = (lang:get-single-input $arguments)

      path:join $caller-dir $relative-path
    }
  ]
}