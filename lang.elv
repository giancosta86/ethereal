#
# If $condition is trueish, $when-true is emitted - $when-false otherwise.
#
fn ternary { |condition when-true when-false|
  if $condition {
    put $when-true
  } else {
    put $when-false
  }
}

#
# This function is designed to be called from a function whose argument list ends with @arguments,
# so as to support both pipe input and argument input at once; it emits:
#
# * the single argument contained in the argument list, if such list is not empty.
#
# * the single value passed via pipe, otherwise.
#
# In both cases, if more than one value is passed, an exception is thrown.
#
# To use this function, simply call it passing the `$arguments` list.
#
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

#
# This function is designed to be called from a function whose argument list ends with @arguments,
# so as to support both pipe input and argument input at once; it emits:
#
# * all the arguments contained in the argument list, if such list is not empty.
#
# * the values passed via pipe, otherwise.
#
# To use this function, simply call it passing the `$arguments` list.
#
fn get-inputs { |argument-list|
  if (== (count $argument-list) 0) {
    all
  } else {
    all $argument-list
  }
}

#
# Returns $true if is input value is a function, $false otherwise.
#
fn is-function { |@arguments|
  get-single-input $arguments |
    kind-of (all) |
    eq (all) "fn"
}

#
# Minimalist filter forwarding every single pipe input it receives;
# however, if there are no such inputs, it emits a customizable default value.
#
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

#
# Emits the given input value as it is, except a few cases:
#
# * numbers are expressed as the «X» string.
#
# * lists are recursively processed so that every value is minimized.
#
# * maps are recursively processed so that keys and values are minimized.
#
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
      put [(minimize $key) (minimize $map[$key])]
    } |
      make-map
  }
]