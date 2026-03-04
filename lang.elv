pragma unknown-command = disallow

#
# If `condition` is trueish, `when-true` is emitted - emitting `when-false` otherwise.
#
# Please, note: **both arguments** are evaluated when calling the function!
# Should you need lazy evaluation, use `if` instead!
#
fn ternary { |condition when-true when-false|
  if $condition {
    put $when-true
  } else {
    put $when-false
  }
}

#
# Takes in input - via pipe or as the first argument - a `value`, then compares it
# with the value-block map of `cases` passed as the last argument:
#
# * If `value` is a key in the `cases` map, the associated *no-arg* block is invoked
#
# * Otherwise, the `default` flag is considered:
#
#   * if it's declared, it must be a block taking the **value** as its only parameter
#
#   * otherwise, an explanatory failure is raised
#
# Please, note: both the case blocks and the default block, despite having different signatures,
# can emit any number of values: the `switch` construct is structurally equivalent, for example,
# to the `if` construct.
#
fn switch { |&default=$nil @arguments|
  var value
  var cases

  var argument-count = (count $arguments)

  if (== $argument-count 1) {
    set value = (one)
    set cases = $arguments[0]
  } elif (== $argument-count 2) {
    set value cases = (all $arguments)
  } else {
    fail 'arity error: expected 1 or 2 arguments'
  }

  if (has-key $cases $value) {
    $cases[$value]
  } elif $default {
    $default $value
  } else {
    fail 'Unexpected value in switch: '$value
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
  switch (count $argument-list) [
    &(num 0)={
      one
    }
    &(num 1)={
      put $argument-list[0]
    }
  ] &default={ |_|
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
    ==s (all) fn
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
# * lists are recursively processed so that every numeric value is flattened.
#
# * maps are recursively processed so that numeric keys and values are flattened.
#
# In other words, this function ensures that numbers are always expressed in a consistent, minimalist string way.
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
# If the given `source` object has the given `key`, emits its value;
# otherwise, emits the requested `default` (i.e., $nil, if omitted).
#
fn get-value { |&default=$nil @arguments|
  var source key = (get-inputs $arguments)

  if (has-key $source $key) {
    put $source[$key]
  } else {
    put $default
  }
}

#
# Emits $true if the given value is a sequence, $false otherwise.
#
fn is-seq { |@arguments|
  var value = (get-single-input $arguments)

  try {
    count $value | only-bytes
  } catch {
    put $false
  } else {
    put $true
  }
}

#
# Emits $true if the given value is neither $nil nor an empty sequence, $false otherwise.
#
fn is-substantial { |@arguments|
  var value = (get-single-input $arguments)

  if (is-seq $value) {
    > (count $value) 0
  } else {
    not-eq $value $nil
  }
}

#
# Takes the given function and returns another function forwarding its arguments to the former and then negating its result.
#
fn negate { |base-function|
  put { |@arguments|
    $base-function $@arguments |
      not (one)
  }
}