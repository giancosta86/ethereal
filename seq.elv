use math
use ./lang
use ./string

fn is-empty { |@arguments|
  lang:get-single-input $arguments |
    take 1 |
    count (all) |
    == (all) 0
}

fn is-non-empty { |@arguments|
  lang:get-single-input $arguments |
    take 1 |
    count (all) |
    != (all) 0
}

fn enumerate { |&start-index=0|
  var index = (num $start-index)

  each { |item|
    put [$index $item]
    set index = (+ $index 1)
  }
}

fn each-spread { |consumer|
  each { |items|
    call $consumer $items [&]
  }
}

fn reduce { |&debug=$false initial-value operator|
  if $debug {
    print '🏡INITIAL VALUE: '
    echo (string:pretty $initial-value)
    echo
  } >&2

  var result = $initial-value

  each { |item|
    if $debug {
      print '💰CUMULATED: '
      echo (string:pretty $result)
      echo
      print '⏩CURRENT ITEM: '
      echo (string:pretty $item)
      echo
    } >&2

    set result = ($operator $result $item)
  }

  if $debug {
    print '💡RESULT: '
    pprint $result
  } >&2

  put $result
}

fn get-at { |&default=$nil source index|
  if (> (count $source) $index) {
    put $source[$index]
  } else {
    put $default
  }
}

fn get-prefix { |left right|
  var result = []

  range 0 (math:min (count $left) (count $right)) |
    each { |index|
      if (eq $left[$index] $right[$index]) {
        set result = [$@result $left[$index]]
      } else {
        break
      }
    }

  put $result
}

fn empty-to-default { |&default=$nil @arguments|
  var source = (lang:get-single-input $arguments)

  > (count $source) 0 |
    lang:ternary (all) $source $default
}

fn split-by-chunk-count { |chunk-count|
  if (<= $chunk-count 0) {
    fail 'The chunk count must be > 0! Requested: '$chunk-count
  }

  var chunks = [(repeat $chunk-count [])]

  var chunk-index = 0

  each { |item|
    var current-chunk = $chunks[$chunk-index]

    var updated-chunk = [$@current-chunk $item]

    set chunks = (assoc $chunks $chunk-index $updated-chunk)

    set chunk-index = (
      + $chunk-index 1 |
        % (all) $chunk-count
    )
  }

  all $chunks |
    keep-if { |chunk| not-eq $chunk [] }
}

fn value-as-list { |@arguments|
  var value = (lang:get-single-input $arguments)

  not-eq $value $nil |
    lang:ternary (all) [$value] []
}

fn equivalence-classes { |&equality=$eq~|
  var classes-by-representative = (
    reduce [&] { |cumulated-map value|
      var added = $false

      keys $cumulated-map | each { |class-representative|
        if ($equality $value $class-representative) {
          var equivalence-class = $cumulated-map[$class-representative]

          var updated-class = [$@equivalence-class $value]

          assoc $cumulated-map $class-representative $updated-class

          set added = $true

          break
        }
      }

      if (not $added) {
        assoc $cumulated-map $value [$value]
      }
    }
  )

  keys $classes-by-representative | each { |representative|
    put $classes-by-representative[$representative]
  }
}