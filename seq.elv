use math
use ./lang
use ./string

#
# Emits $true if the passed input sequence has no items, $false otherwise.
#
fn is-empty { |@arguments|
  lang:get-single-input $arguments |
    take 1 |
    count (all) |
    == (all) 0
}

#
# Emits $true if the passed input sequence has at least one item, $false otherwise.
#
fn is-non-empty { |@arguments|
  lang:get-single-input $arguments |
    take 1 |
    count (all) |
    != (all) 0
}

#
# Takes in input a sequence and emits `[index item]` pairs.
#
# The `start-index` flag can be used to start the sequence from the given value.
#
fn enumerate { |&start-index=0 @arguments|
  var index = (num $start-index)

  lang:get-inputs $arguments |
    each { |item|
      put [$index $item]
      set index = (+ $index 1)
    }
}

#
# For each item received via pipe, which must be a sequence,
# calls the given `consumer` - passing each sub-item as an argument, in order.
#
fn spread { |consumer|
  each { |current-sequence|
    call $consumer $current-sequence [&]
  }
}

#
# Starts from the given `initial-value`, setting it as partial result,
# then, for each value passed via pipe, calls `operator`, which must
# receive two arguments:
#
# * the latest partial result
#
# * the current item
#
# and must emit the new partial result.
#
# In the end, returns the most recent partial result; as a plus, the `debug` flag
# enables useful debug messages.
#
# Please, note: the `operator` function can call `break` or `continue` to influence the loop.
#
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

#
# Given two sequences, emits the longest initial subsequence shared by both.
#
fn get-prefix { |left right|
  range 0 (math:min (count $left) (count $right)) |
    reduce [] { |partial index|
      if (eq $left[$index] $right[$index]) {
        put [$@partial $left[$index]]
      } else {
        break
      }
    }
}

#
# If the input collection is empty, emits a default value of any kind;
# otherwise, emits the collection itself.
#
fn coalesce-empty { |&default=$nil @arguments|
  var source = (lang:get-single-input $arguments)

  > (count $source) 0 |
    lang:ternary (all) $source $default
}

#
# Creates the given (positive) number of chunks, then subdivides the items received via pipe
# into such chunks, with a round-robin algorithm.
#
# In the end, emits the non-empty chunks as separate values.
#
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

#
# If the given input value is not $nil, emits a list containing just that value;
# otherwise, emits an empty list.
#
fn value-as-list { |@arguments|
  var value = (lang:get-single-input $arguments)

  not-eq $value $nil |
    lang:ternary (all) [$value] []
}

#
# Splits the values received via pipe into equivalence classes,
# i.e., lists whose items are pairwise equal according to
# the given `equality` function - which must take two arguments
# and emit $true if they are to be considered equal.
#
# The default equality algorithm is the builtin `eq` function.
#
# The items are appended to each class as they are extracted from the pipe,
# in arrival order.
#
# In the end, emits all the equivalence classes, one by one.
#
fn equivalence-classes { |&equality=$eq~|
  var classes-by-representative = (
    reduce [&] { |cumulated-map value|
      var belonging-to-a-class = $false

      keys $cumulated-map | each { |class-representative|
        if ($equality $value $class-representative) {
          var equivalence-class = $cumulated-map[$class-representative]

          var updated-class = [$@equivalence-class $value]

          assoc $cumulated-map $class-representative $updated-class

          set belonging-to-a-class = $true

          break
        }
      }

      if (not $belonging-to-a-class) {
        assoc $cumulated-map $value [$value]
      }
    }
  )

  keys $classes-by-representative | each { |representative|
    put $classes-by-representative[$representative]
  }
}