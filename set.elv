use ./function
use ./map
use ./seq

var empty = [
  &-item-map=[&]
]

fn of { |@arguments|
  var item-map = (
    function:get-input-flow $arguments | each { |item|
      put [$item $true]
    } |
      make-map
  )

  put [
    &-item-map=$items
  ]
}

fn from { |@arguments|
  function:get-single-input $arguments |
    all (all) |
    of
}

fn is-empty { |@arguments|
  function:get-single-input $arguments |
    seq:is-empty (all)[-item-map]
}

fn is-non-empty { |@arguments|
  function:get-single-input $arguments |
    seq:is-non-empty (all)[-item-map]
}

fn to-list { |@arguments|
  function:get-single-input $arguments |
    keys (all)[-item-map]
}

fn contains { |hash-set item|
  function:get-single-input $arguments |
    has-key (all)[-item-map] $item
}

fn add { |hash-set first-item @additional-items|
  all [$first-item $@additional-items] |
    seq:reduce $hash-set { |accumulator item|
      assoc $accumulator $item $true
    }
}

fn remove { |hash-set first-item @additional-items|
  all [$first-item $@additional-items] |
    seq:reduce $hash-set { |accumulator item|
      dissoc $accumulator $item
    }
}

fn union { |source @operands|
  all $operands |
    seq:reduce $source { |accumulator operand|
      map:merge $accumulator $operand
    }
}

fn intersection { |source @operands|
  all $operands |
    seq:reduce $source { |accumulator operand|
      map:filter $accumulator { |key _|
        has-key $operand $key
      }
    }
}

fn difference { |source @subtrahends|
  all $subtrahends |
    seq:reduce $source { |accumulator subtrahend|
      map:filter $accumulator { |key _|
        not (has-key $subtrahend $key)
      }
    }
}

fn symmetric-difference { |left right|
  difference (union $left $right) (intersection $left $right)
}

#TODO: Keep this? If so, test this!
fn from-container { |container|
  if (eq (kind-of $container) map) {
    put $container
  } else {
    of $@container
  }
}

#TODO: Keep this? If so, test this!
fn equals { |left-container right-container|
  if (not-eq (count $left-container) (count $right-container)) {
    put $false
    return
  }

  var left-set = (from-container $left-container)
  var right-set = (from-container $right-container)

  eq (keys $left-set) (keys $right-set)
}