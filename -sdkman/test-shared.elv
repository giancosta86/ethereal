use os
use path
use ../fs
use ./paths

fn with-temp-candidate { |candidate block|
  fs:with-temp-dir { |temp-dir|
    tmp paths:sdkman-home = $temp-dir

    var candidate-root = (path:join $temp-dir candidates $candidate)

    os:mkdir-all $candidate-root

    $block $candidate-root
  }
}