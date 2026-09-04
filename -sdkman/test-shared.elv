use os
use path
use ../fs
use ./paths

fn with-temp-candidate { |candidate block|
  fs:within-temp-dir {
    tmp paths:sdkman-home = $pwd

    var candidate-root = (path:join $pwd candidates $candidate)

    os:mkdir-all $candidate-root

    $block $candidate-root
  }
}