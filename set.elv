use builtin
use ./lang
use ./map
use ./seq

#
# Set with no items
#
var empty = [
  &-set-items=[&]
]

#
# Take items as input - from either variable argument list or pipe - and
# returns a set containing such items.
#
fn of { |@arguments|
  var set-items = (
    lang:get-inputs $arguments | each { |value|
      put [$value $true]
    } |
      make-map
  )

  put [
    &-set-items=$set-items
  ]
}

#
# Emits a list containing the items of the given input set, in unspecified order.
#
fn to-list { |@arguments|
  lang:get-single-input $arguments |
    keys (all)[-set-items] |
    put [(all)]
}

#
# Emits $true if the given input value is a set - according to this module's format.
#
fn is-set { |@arguments|
  var source = (lang:get-single-input $arguments)

  and (eq (kind-of $source) map) (has-key $source -set-items)
}

#
# Takes a collection - including a set - as single input, and emits a set containing its items.
#
fn from { |@arguments|
  var source = (lang:get-single-input $arguments)

  if (is-set $source) {
    put $source
  } else {
    of (all $source)
  }
}

#
# Emits $true if the input set is empty, $false otherwise.
#
fn is-empty { |@arguments|
  lang:get-single-input $arguments |
    seq:is-empty (all)[-set-items]
}

#
# Emits $true if the input set is not empty, $false otherwise.
#
fn is-non-empty { |@arguments|
  lang:get-single-input $arguments |
    seq:is-non-empty (all)[-set-items]
}

#
# Emits the number of items in the input set.
#
fn count { |@arguments|
  lang:get-single-input $arguments |
    builtin:count (all)[-set-items]
}

#
# Emits $true if the given `reference-set` has the given input value - passed as argument or via pipe.
#
fn has-value { |reference-set @arguments|
  var value = (lang:get-single-input $arguments)

  has-key $reference-set[-set-items] $value
}

#
# Takes a `base-set` as well as - via argument or pipe - one or more values,
# emitting a set equal to the base set plus the input values.
#
fn add { |base-set @arguments|
  var updated-set-items = (
    lang:get-inputs $arguments |
      seq:reduce $base-set[-set-items] { |cumulated-items value|
        assoc $cumulated-items $value $true
      }
  )

  put [
    &-set-items=$updated-set-items
  ]
}

#
# Takes a `base-set` as well as - via argument or pipe - one or more values,
# emitting a set equal to the base set minus the input values.
#
fn remove { |base-set @arguments|
  var updated-set-items = (
    lang:get-inputs $arguments |
      seq:reduce $base-set[-set-items] { |cumulated-items value|
        dissoc $cumulated-items $value
      }
  )

  put [
    &-set-items=$updated-set-items
  ]
}

#
# Takes in input source sets - via pipe or arguments - and emits their union.
#
fn union { |@arguments|
  var result-items = (
    lang:get-inputs $arguments |
      put (all)[-set-items] |
      map:merge
  )

  put [
    &-set-items=$result-items
  ]
}

#
# Takes in input source sets - via pipe or arguments - and emits their intersection.
#
fn intersection { |@arguments|
  var first @others = (
    lang:get-inputs $arguments |
      lang:ensure-put &default=$empty
  )

  if (eq $first $empty) {
    put $empty
    return
  }

  var result-items = (
    all $others |
      seq:reduce $first[-set-items] { |cumulated-items operand|
        map:keep-if $cumulated-items { |key _|
          has-key $operand[-set-items] $key
        }
      }
  )

  put [
    &-set-items=$result-items
  ]
}

#
# Takes in input source sets - via pipe or arguments - and emits their difference.
#
fn difference { |@arguments|
  var first @others = (
    lang:get-inputs $arguments |
      lang:ensure-put &default=$empty
  )

  if (eq $first $empty) {
    put $empty
    return
  }

  var result-items = (
    all $others |
      seq:reduce $first[-set-items] { |cumulated-items operand|
        map:keep-if $cumulated-items { |key _|
          not (has-key $operand[-set-items] $key)
        }
      }
  )

  put [
    &-set-items=$result-items
  ]
}

#
# Takes 2 sets - either as arguments or from pipe - and emits
# their symmetric difference.
#
fn symmetric-difference { |@arguments|
  var left right = (lang:get-inputs $arguments)

  difference (union $left $right) (intersection $left $right)
}