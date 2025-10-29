fn is-function { |value|
  ==s (kind-of $value) "fn"
}

fn ternary { |condition when-true when-false|
  if $condition {
    put $when-true
  } else {
    put $when-false
  }
}

fn ensure-put { |&default=$nil|
  var emitted = $false

  each { |value-sent-to-put|
    set emitted = $true

    put $value-sent-to-put
  }

  if (not $emitted) {
    put $default
  }
}

var -minimal-transforms-by-kind

fn minimize { |value|
  var kind = (kind-of $value)

  if (has-key $-minimal-transforms-by-kind $kind) {
    $-minimal-transforms-by-kind[$kind] $value
  } else {
    to-string $value
  }
}

set -minimal-transforms-by-kind = [
  &list={ |list|
    all $list |
      each $minimize~ |
      put [(all)]
  }
  &map={ |map|
    keys $map | each { |key|
      var value = $map[$key]
      put [(minimize $key) (minimize $value)]
    } |
      make-map
  }
]
