use ./lang
use ./seq

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
    seq:spread { |key value|
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

fn multi-value { |@arguments|
  lang:get-inputs $arguments |
    seq:reduce [&] { |cumulated-map entry|
      var key value = (put $@entry)

      var existing-values = (lang:get-value $cumulated-map $key &default=[])

      var updated-values = [$@existing-values $value]

      assoc $cumulated-map $key $updated-values
    }
}