use os
use ./lang

var -redirectors-by-stream = [
  &both={ |block|
    put { $block 2>&1 }
  }

  &out={ |block|
    put { $block 2>$os:dev-null }
  }

  &err={ |block|
    put {
      { $block | only-bytes } 2>&1 >$os:dev-null
    }
  }

  &none={ |block|
    put {
      { $block | only-bytes } >$os:dev-null 2>&1
    }
  }
]

var -data-filter-by-type = [
  &both={ |block|
    put $block
  }

  &bytes={ |block|
    put { $block | only-bytes }
  }

  &values={ |block|
    put { $block | only-values }
  }

  &none={ |block|
    put { $block | only-bytes | only-values }
  }
]

#
# Runs the given block and:
#
# * captures its emitted data as a list containing bytes/values:
#
#   * from stream **out**, **err**, **both** or **none**, according to the `stream` option
#
#   * of type **bytes**, **values**, **both** or **none**, according to the `type` option
#
# * intercepts its thrown exception, if any - or $nil if the block runs flawlessly.
#
# In the end, emits a map containing the `data` and `exception` keys.
#
fn capture { |&stream=both &type=both @arguments|
  if (not (has-key $-redirectors-by-stream $stream)) {
    fail 'Invalid stream option: '$stream
  }

  if (not (has-key $-data-filter-by-type $type)) {
    fail 'Invalid type option: '$type
  }

  var block = (lang:get-single-input $arguments)

  var redirector~ = $-redirectors-by-stream[$stream]
  var data-filter~ = $-data-filter-by-type[$type]

  var decorated-block = (
    put $block |
      redirector (all) |
      data-filter (all)
  )

  var exception = $nil

  var data = (
    {
      try {
        $decorated-block
      } catch e {
        set exception = $e
      }
    } |
      put [(all)]
  )

  put [
    &data=$data
    &exception=$exception
  ]
}

var -silence-exception-strategies = [
  &both={ |capture-result|
    all $capture-result[data] | each { |item|
      echo $item
    }

    fail $capture-result[exception]
  }

  &data={ |capture-result|
    all $capture-result[data] | each { |item|
      echo $item
    }
  }

  &exception={ |capture-result|
    fail $capture-result[exception]
  }

  &none={ |_| }
]

#
# Silences the given block - preventing it from emitting anything from both stdout and stderr.
#
# In case of exception, the `on-exception` option dictates the strategy:
#
# * **both**: outputs to stdout every line/value emitted by the command, then throws the exception.
#
# * **data**: outputs to stdout every line/value emitted by the command, but does not throw the exception.
#
# * **exception**: just throws the exception.
#
# * **none**: just does nothing.
#
fn silence { |&on-exception=both @arguments|
  if (not (has-key $-silence-exception-strategies $on-exception)) {
    fail 'Invalid value for the "&on-exception" option: '$on-exception
  }

  var command = (lang:get-single-input $arguments)

  var capture-result = (
    capture &stream=both &type=both $command
  )

  if (not-eq $capture-result[exception] $nil) {
    $-silence-exception-strategies[$on-exception] $capture-result
  }
}

#
# Emits $true if the given command is available in Bash - even as an alias - by invoking `type`;
# otherwise, emits $false.
#
fn exists-in-bash { |@arguments|
  var command = (lang:get-single-input $arguments)

  put ?(bash --rcfile ~/.bashrc -i -c 'type '$command > $os:dev-null 2>&1) |
    eq $ok (all)
}

#
# Creates a map - especially useful in tests - with the following keys:
#
# * `command`: a command that can be invoked - with any number of arguments; it takes track of its arguments, then executes the optional block argument, passing its arguments.
#
# * `get-runs`: emits the list of runs of the above `command` up to that moment - where each run is stored in a sublist containing its arguments.
#
fn spy { |@arguments|
  var block = (lang:get-value $arguments 0)

  var runs = []

  put [
    &get-runs={
      put $runs
    }

    &command={ |@arguments|
      set runs = [
        $@runs
        $arguments
      ]

      if $block {
        $block $@arguments
      }
    }
  ]
}