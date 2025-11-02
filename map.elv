use ./lang
use ./seq

fn get-value { |&default=$nil source key|
  if (has-key $source $key) {
    put $source[$key]
  } else {
    put $default
  }
}

fn entries { |@arguments|
  var source = (lang:get-single-input $arguments)

  keys $source | each { |key|
    put [$key $source[$key]]
  }
}

fn values { |@arguments|
  var source = (lang:get-single-input $arguments)

  keys $source | each { |key|
    put $source[$key]
  }
}

fn merge { |@arguments|
  lang:get-inputs $arguments |
    each $entries~ |
    seq:reduce [&] { |accumulator entry|
      var key value = (all $entry)
      assoc $accumulator $key $value
    }
}

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

fn filter { |source key-value-predicate|
  entries $source |
    seq:each-spread { |key value|
      if ($key-value-predicate $key $value) {
        put [$key $value]
      }
    } |
    make-map
}

fn filter-map { |source mapper|
  keys $source |
    each { |key|
      var value = $source[$key]

      var new-pair = ($mapper $key $value)

      if (not-eq $new-pair $nil) {
        put $new-pair
      }
    } |
    make-map
}