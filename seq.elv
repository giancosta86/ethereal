use math
use ./lang

fn is-empty { |container| == (count $container) 0 }

fn is-non-empty { |container| != (count $container) 0 }

#TODO! Test start-index!
fn enumerate { |&start-index=0 consumer|
  var index = (num $start-index)

  each { |item|
    $consumer $index $item
    set index = (+ $index 1)
  }
}

fn each-spread { |consumer|
  each { |items|
    call $consumer $items [&]
  }
}

fn reduce { |initial-value operator|
  var result = $initial-value

  each { |item|
    set result = ($operator $result $item)
  }

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

fn empty-to-default { |&default=$nil source|
  lang:ternary (> (count $source) 0) $source $default
}

#TODO! Test this!
fn split-by-chunk-count { |chunk-count|
  if (<= $chunk-count 0) {
    fail 'The chunk count must be > 0! Requested: '$chunk-count
  }

  var chunks = (
    range 0 $chunk-count | each { |_|
      put []
    } |
      put [(all)]
  )

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

  put $chunks
}