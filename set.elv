use builtin
use ./lang
use ./map
use ./seq

var empty = [
  &-set-items=[&]
]

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

fn to-list { |@arguments|
  lang:get-single-input $arguments |
    keys (all)[-set-items] |
    put [(all)]
}

fn is-set { |@arguments|
  var source = (lang:get-single-input $arguments)

  and (eq (kind-of $source) map) (has-key $source -set-items)
}

fn from { |@arguments|
  var source = (lang:get-single-input $arguments)

  if (is-set $source) {
    put [
      &-set-items=$source[-set-items]
    ]
  } else {
    of (all $source)
  }
}

fn is-empty { |@arguments|
  lang:get-single-input $arguments |
    seq:is-empty (all)[-set-items]
}

fn is-non-empty { |@arguments|
  lang:get-single-input $arguments |
    seq:is-non-empty (all)[-set-items]
}

fn count { |@arguments|
  lang:get-single-input $arguments |
    builtin:count (all)[-set-items]
}

fn has-value { |reference-set @arguments|
  var value = (lang:get-single-input $arguments)

  has-key $reference-set[-set-items] $value
}

fn add { |reference-set @arguments|
  var updated-set-items = (
    lang:get-inputs $arguments |
      seq:reduce $reference-set[-set-items] { |cumulated-items value|
        assoc $cumulated-items $value $true
      }
  )

  put [
    &-set-items=$updated-set-items
  ]
}

fn remove { |reference-set @arguments|
  var updated-set-items = (
    lang:get-inputs $arguments |
      seq:reduce $reference-set[-set-items] { |cumulated-items value|
        dissoc $cumulated-items $value
      }
  )

  put [
    &-set-items=$updated-set-items
  ]
}

fn union { |@arguments|
  var result-items = (
    lang:get-inputs $arguments |
      seq:reduce [&] { |cumulated-items operand|
        map:merge $cumulated-items $operand[-set-items]
      }
  )

  put [
    &-set-items=$result-items
  ]
}

fn intersection { |@arguments|
  var operands = [(lang:get-inputs $arguments)]

  if (seq:is-empty $operands) {
    put $empty
    return
  }

  var result-items = (
    all $operands |
      drop 1 |
      seq:reduce $operands[0][-set-items] { |cumulated-items operand|
        map:filter $cumulated-items { |key _|
          has-key $operand[-set-items] $key
        }
      }
  )

  put [
    &-set-items=$result-items
  ]
}

fn difference { |@arguments|
  var operands = [(lang:get-inputs $arguments)]

  if (seq:is-empty $operands) {
    put $empty
    return
  }

  var result-items = (
    all $operands |
      drop 1 |
      seq:reduce $operands[0][-set-items] { |cumulated-items operand|
        map:filter $cumulated-items { |key _|
          not (has-key $operand[-set-items] $key)
        }
      }
  )

  put [
    &-set-items=$result-items
  ]
}

fn symmetric-difference { |@arguments|
  var left right = (lang:get-inputs $arguments)

  difference (union $left $right) (intersection $left $right)
}