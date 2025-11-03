fn ternary { |condition when-true when-false|
  if $condition {
    put $when-true
  } else {
    put $when-false
  }
}

fn get-single-input { |argument-list|
  var arg-count = (count $argument-list)

  if (== $arg-count 0) {
    one
  } elif (== $arg-count 1) {
    put $argument-list[0]
  } else {
    fail 'arity mismatch: at most 1 argument expected!'
  }
}

fn get-inputs { |argument-list|
  if (> (count $argument-list) 0) {
    all $argument-list
  } else {
    all
  }
}

fn is-function { |@arguments|
  get-single-input $arguments |
    kind-of (all) |
    ==s (all) "fn"
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

fn minimize { |@arguments|
  var value = (get-single-input $arguments)

  var kind = (kind-of $value)

  if (has-key $-minimal-transforms-by-kind $kind) {
    $-minimal-transforms-by-kind[$kind] $value
  } else {
    put $value
  }
}

set -minimal-transforms-by-kind = [
  &number={ |value|
    to-string $value
  }
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

fn no-output {
  all | only-bytes
}