use ./seq

fn get-value { |&default=$nil source key|
  if (has-key $source $key) {
    put $source[$key]
  } else {
    put $default
  }
}

fn entries { |source|
  keys $source | each { |key|
    put [$key $source[$key]]
  }
}

fn values { |map|
  entries $map |
    seq:each-spread { |_ value| put $value }
}

fn merge { |@sources|
  all $sources |
    each $entries~ |
    seq:reduce [&] { |accumulator entry|
      var key value = (all $entry)
      assoc $accumulator $key $value
    }
}

fn drill-down { |&default=$nil source @properties|
  var current-source = $source

  all $properties | each { |property|
    var value = (get-value $current-source $property)

    if $value {
      set current-source = $value
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

fn assoc-non-nil { |map key value|
  if $value {
    assoc $map $key $value
  } else {
    put $map
  }
}

#TODO! Test this!
#TODO! rewrite most functions referencing make-map, so as to use map:map!
fn map { |source mapper|
  entries $source |
    seq:each-spread { |key value|
      $mapper $key $value
    } |
      make-map
}