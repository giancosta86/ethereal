use ./lang
use ./seq

pragma unknown-command = disallow

#
# Iterates over the given map - which can be passed via pipe or
# as the first argument - and, for each of its entries, calls the
# consumer - a binary function passed as the last argument and
# taking the key and the value, respectively, as arguments.
#
fn iterate { |@arguments|
  var argument-count = (count $arguments)

  var map
  var consumer

  if (== $argument-count 1) {
    set map = (one)
    set consumer = $arguments[0]
  } elif (== $argument-count 2) {
    set map = $arguments[0]
    set consumer = $arguments[1]
  } else {
    fail 'arity mismatch: <consumer> or <map><consumer> expected'
  }

  keys $map | each { |key|
    $consumer $key $map[$key]
  }
}

#
# Emits the entries of the given map as a stream of [key value] pairs.
#
fn entries { |@arguments|
  var source = (lang:get-single-input $arguments)

  iterate $source { |key value|
    put [$key $value]
  }
}


#
# Emits the values of the given map, according to the internal map order.
#
fn values { |@arguments|
  lang:get-single-input $arguments |
    iterate { |_ value| put $value }
}

#
# Takes an arbitrary stream of maps as input and emits a map merging them.
#
# In case of duplicated keys, the latest map takes precedence.
#
fn merge { |@arguments|
  lang:get-inputs $arguments |
    each $entries~ |
    make-map
}

#
# Takes as arguments a `source` map, whose `[key value]` pairs are passed, one by one, to the given `mapper` function,
# which must take the key and the value as separate arguments and emit an arbitrary (even empty)
# stream of related entries for the result map.
#
fn transform { |source mapper|
  iterate $source { |key value|
    $mapper $key $value
  } |
    make-map
}

#
# Takes a `source` map and a predicate - taking a key and a value, and emitting $true
# if the entry must be preserved in the result map.
#
fn keep-if { |source key-value-predicate|
  transform $source { |key value|
    if ($key-value-predicate $key $value) {
      put [$key $value]
    }
  }
}

#
# Converts a stream of [key value] pairs into a map where each key always has a list value,
# which contains all the values, from the input pairs, related to such key.
#
# The values are added to each list in arrival order from the input.
#
fn multi-value { |@arguments|
  lang:get-inputs $arguments |
    seq:reduce [&] { |cumulated-map entry|
      var key value = (put $@entry)

      var existing-values = (lang:get-value $cumulated-map $key &default=[])

      var updated-values = (conj $existing-values $value)

      assoc $cumulated-map $key $updated-values
    }
}