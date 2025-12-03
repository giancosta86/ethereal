pragma unknown-command = disallow

#
# If `condition` is trueish, `when-true` is emitted - emitting `when-false` otherwise.
#
fn ternary { |condition when-true when-false|
  if $condition {
    put $when-true
  } else {
    put $when-false
  }
}

#
# This function is designed to be called from within a function whose argument list ends with @arguments,
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
# This function is designed to be called from within a function whose argument list ends with @arguments,
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
# Emits $true if its input value is a function, $false otherwise.
#
fn is-function { |@arguments|
  get-single-input $arguments |
    kind-of (all) |
    eq (all) fn
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

var -flat-num-transforms-by-kind

#
# Emits the given input value as it is, except a few cases:
#
# * numbers are expressed as the more compact «X» string.
#
# * lists are recursively processed so that every numeric value if flattened.
#
# * maps are recursively processed so that numeric keys and values are flattened.
#
# In other words, this function ensures that numbers are always expressed in a consistent, minimalist way.
#
fn flat-num { |@arguments|
  var value = (get-single-input $arguments)

  var kind = (kind-of $value)

  if (has-key $-flat-num-transforms-by-kind $kind) {
    $-flat-num-transforms-by-kind[$kind] $value
  } else {
    put $value
  }
}

set -flat-num-transforms-by-kind = [
  &number={ |value|
    to-string $value
  }
  &list={ |list|
    all $list |
      each $flat-num~ |
      put [(all)]
  }
  &map={ |map|
    keys $map | each { |key|
      put [(flat-num $key) (flat-num $map[$key])]
    } |
      make-map
  }
]

#
# If the input value is a block, emits the (single) value emitted by such function;
# otherwise, emits the value itself.
#
fn resolve { |@arguments|
  var value = (get-single-input $arguments)

  if (is-function $value) {
    $value |
      one
  } else {
    put $value
  }
}

#
# If the given `source` sequence has the given `key`, emits its value;
# otherwise, emits the requested `default` (by default, $nil).
#
fn get-value { |&default=$nil @arguments|
  var source key = (get-inputs $arguments)

  if (has-key $source $key) {
    put $source[$key]
  } else {
    put $default
  }
}