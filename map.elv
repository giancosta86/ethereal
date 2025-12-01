use ./lang
use ./seq

pragma unknown-command = disallow

#
# Emits the entries of the given map as a stream of [key value] pairs.
#
fn entries { |@arguments|
  var source = (lang:get-single-input $arguments)

  keys $source | each { |key|
    put [$key $source[$key]]
  }
}

#
# Emits the values of the given map, according to the internal map order.
#
fn values { |@arguments|
  var source = (lang:get-single-input $arguments)

  keys $source | each { |key|
    put $source[$key]
  }
}

#
# Takes an arbitrary stream of maps in input and emits a map merging them.
#
# In case of duplicated keys, the latest map takes precedence.
#
fn merge { |@arguments|
  lang:get-inputs $arguments |
    each $entries~ |
    make-map
}

#
# Takes the given `source` recursive map and expects every successive argument to be the key
# to a map level; if any of such keys is not found in the related map, the `default` value is emitted.
#
fn drill-down { |&default=$nil source @properties|
  var current-source = $source

  all $properties | each { |property|
    if (has-key $current-source $property) {
      set current-source = $current-source[$property]
    } else {
      put $default
      return
    }
  }

  put $current-source
}

#
# Takes a `source` map, whose `[key value]` pairs are passed to the given `mapper` function,
# which must take the key and the value as separate arguments and emit an arbitrary (even empty)
# stream of related entries for the result map.
#
fn transform { |source mapper|
  keys $source |
    each { |key|
      $mapper $key $source[$key]
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

      var updated-values = [$@existing-values $value]

      assoc $cumulated-map $key $updated-values
    }
}