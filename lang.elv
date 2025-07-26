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

#TODO! Test this, and try to apply it as much as possible!
fn value-as-list { |value|
  ternary $value [$value] []
}