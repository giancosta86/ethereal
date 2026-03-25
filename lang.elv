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
# This function is designed to be called from within a function whose argument list ends with @arguments;
# it reads a number of inputs - from pipe and/or arguments - according to the following logic:
#
# 1. Detect the number of arguments in `argument-list`, ensuring it is no less than &min-args.
#
# 2. If there are no arguments - or if the number of arguments is less then &min-values - read all the values in the pipe.
#
# 3. Create a list of values, by combining in this order:
#
#    * the data read from the pipe at the previous step - or an empty list if the pipe was not accessed
#
#    * the arguments
#
# 4. Ensure that the overall number of values is in the [&min-values; &max-values] range.
#
# In the end, the resulting values are emitted one by one.
#
# To use this function, you'll need to pass at least the `$arguments` list.
#
fn get-mixed-inputs { |&min-values=0 &max-values=$nil &min-args=0 argument-list|
  if $max-values {
    if (> $min-values $max-values) {
      fail 'It must be &min-values <= &max-values'
    }

    if (> $min-args $max-values) {
      fail 'It must be &min-args <= &max-values'
    }
  }

  var arg-count = (count $argument-list)

  if (< $arg-count $min-args) {
    fail 'At least '$min-args' argument(s) must be passed, not just '$arg-count
  }

  var piped = (
    if (
      or (== $arg-count 0) (< $arg-count $min-values)
    ) {
      put [(all)]
    } else {
      put []
    }
  )

  var values = (conj $piped $@argument-list)

  var value-count = (count $values)

  if (< $value-count $min-values) {
    fail 'At least '$min-values' value(s) must be passed via pipe or arguments - not just '$value-count
  }

  if (and $max-values (> $value-count $max-values)) {
    fail 'At most '$max-values' value(s) can be passed via pipe or arguments - not '$value-count
  }

  all $values
}

#
# Takes in input - via pipe or as arguments - a `value` and value-block map of `cases`, then compares `value`
# with the keys in the map:
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
  var value cases = (get-mixed-inputs &min-values=2 &max-values=2 &min-args=1 $arguments)

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
  get-mixed-inputs &min-values=1 &max-values=1 $argument-list
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
  get-mixed-inputs &min-values=0 $argument-list
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
var flat-num~ = (
  var transforms-by-kind

  var actual-flat-num~ = { |@arguments|
    var value = (get-single-input $arguments)

    var kind = (kind-of $value)

    if (has-key $transforms-by-kind $kind) {
      $transforms-by-kind[$kind] $value
    } else {
      put $value
    }
  }

  set transforms-by-kind = [
    &number={ |value|
      to-string $value
    }
    &list={ |list|
      all $list |
        each $actual-flat-num~ |
        put [(all)]
    }
    &map={ |map|
      keys $map | each { |key|
        put [(actual-flat-num $key) (actual-flat-num $map[$key])]
      } |
        make-map
    }
  ]

  put $actual-flat-num~
)

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

#
# Emits $true if the input value is an exception, $false otherwise.
#
fn is-exception { |@arguments|
  get-single-input $arguments |
    kind-of (all) |
    eq (all) exception
}