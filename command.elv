use os
use ./fs
use ./lang
use ./map
use ./seq

pragma unknown-command = disallow

var -bash~ = (external bash)

#
# Runs the given block provided as input and:
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
var capture~ = (
  #
  # Each redirector takes in input a block and returns another block,
  # where the original block is called, but with altered stdout/stderr.
  #
  var redirectors-by-stream = [
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

  #
  # Each filter takes in input a block and returns another block,
  # where the original block is called with downstream byte/value filters.
  #
  var data-filter-by-type = [
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

  put { |&stream=both &type=both @arguments|
    if (not (has-key $redirectors-by-stream $stream)) {
      fail 'Invalid stream option: '$stream
    }

    if (not (has-key $data-filter-by-type $type)) {
      fail 'Invalid type option: '$type
    }

    var block = (lang:get-single-input $arguments)

    var redirector = $redirectors-by-stream[$stream]
    var data-filter = $data-filter-by-type[$type]

    var decorated-block = (
      put $block |
        $redirector (all) |
        $data-filter (all)
    )

    var exception = $nil

    var data = [(
      {
        try {
          $decorated-block
        } catch e {
          set exception = $e
        }
      }
    )]

    put [
      &data=$data
      &exception=$exception
    ]
  }
)

#
# Silences the given block - preventing it from emitting anything from both stdout and stderr.
#
# In case of exception, the `on-exception` option selects the strategy:
#
# * **both**: outputs to stdout every line/value emitted by the command, then throws the exception. This is the default.
#
# * **data**: outputs to stdout every line/value emitted by the command, but does not throw the exception.
#
# * **exception**: just throws the exception.
#
# * **none**: just does nothing.
#
var silence~ = (
  var strategies = [
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

  put { |&on-exception=both @arguments|
    if (not (has-key $strategies $on-exception)) {
      fail 'Invalid value for the "&on-exception" option: '$on-exception
    }

    var command = (lang:get-single-input $arguments)

    var capture-result = (
      capture &stream=both &type=both $command
    )

    if (not-eq $capture-result[exception] $nil) {
      $strategies[$on-exception] $capture-result
    }
  }
)

#
# Runs the given block of code, hiding its stdout and stderr by default; however, if an error occurs:
#
# 1. the collected stdout and stderr are emitted to stderr
#
# 2. the exception is thrown
#
fn silence-unless-error { |@arguments|
  deprecate 'Use just `silence` instead'

  var block = (lang:get-single-input $arguments)

  var capture-result = (capture $block)

  if (not-eq $capture-result[exception] $nil) {
    all $capture-result[data] |
      each $echo~ >&2

    fail $capture-result[exception]
  }
}

#
# Emits $true if the given command is available in Bash - even as an alias - by invoking `type`;
# otherwise, emits $false.
#
fn exists-in-bash { |@arguments|
  var command = (lang:get-single-input $arguments)

  put ?(-bash --rcfile ~/.bashrc -i -c 'type '$command > $os:dev-null 2>&1) |
    eq $ok (all)
}

#
# Takes as optional argument a block and creates a map - especially useful in tests - with the following keys:
#
# * `command`: a command that can be invoked - with any number of arguments; upon invocation, it adds the current arguments to its log, then executes the optional block (if present), passing the arguments.
#
# * `get-runs`: emits the list of runs of the above `command` up to that moment - where each run is represented by a sublist containing the arguments for that specific run.
#
fn spy { |@arguments|
  var block = (lang:get-value $arguments 0)

  var runs = []

  put [
    &get-runs={
      put $runs
    }

    &command={ |@arguments|
      set runs = (conj $runs $arguments)

      if $block {
        $block $@arguments
      }
    }
  ]
}

#
# Given a list of environment variable names as argument
# and a Bash command line as a string passed via pipe or as argument,
# executes the command line, then:
#
# * if the execution was successful:
#
#   * emits the output of the Bash process
#
#   * sets the requested environment variables in Elvish to the values within Bash right after the command,
#     defaulting to empty values
#
# * on failure:
#
#   * emits as much output as possible from the Bash process
#
#   * lets the exception propagate
#
#   * leaves the environment variables unaltered
#
fn update-env-via-bash { |env-vars @arguments|
  var command-line = (lang:get-single-input $arguments)

  var temp-files-by-env-var = (
    all $env-vars | each { |env-var|
      put [$env-var (fs:temp-file-path)]
    } |
      make-map
  )

  defer {
    map:values $temp-files-by-env-var |
      each $os:remove-all~
  }

  var extended-command-line = (
    map:keys $temp-files-by-env-var |
      seq:reduce $command-line { |cumulated env-var|
        var temp-file = $temp-files-by-env-var[$env-var]

        put $cumulated' && echo -n ${'$env-var':-} > '$temp-file
      }
  )

  -bash -c $extended-command-line

  map:iterate $temp-files-by-env-var { |env-var temp-file|
    slurp < $temp-file |
      set-env $env-var (all)
  }
}