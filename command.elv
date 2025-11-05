use os

fn exists-in-bash { |command|
  eq $ok ?(bash --rcfile ~/.bashrc -i -c 'type '$command > $os:dev-null 2>&1)
}

var -byte-capturers = [
  &both={ |block|
    $block 2>&1
  }

  &out={ |block|
    $block 2>$os:dev-null
  }

  &err={ |block|
    $block 2>&1 >$os:dev-null
  }

  &none={ |block|
    $block >$os:dev-null 2>&1
  }
]

fn capture { |&keep-stream=both block|
  if (not (has-key $-byte-capturers $keep-stream)) {
    fail 'Invalid stream setting: '$keep-stream
  }

  var byte-capturer = $-byte-capturers[$keep-stream]

  var exception = $nil

  var output = (
    try {
      $byte-capturer { $block | only-bytes } |
        slurp
    } catch e {
      set exception = $e
    }
  )

  put [
    &output=$output
    &exception=$exception
  ]
}

fn silence { |block|
  capture &keep-stream=none $block | only-bytes
}

fn silence-until-exception { |&description=$nil block|
  var capture-result = (capture $block)

  if (eq $capture-result[exception] $nil) {
    return
  }

  var actual-description = (coalesce $description 'Exception while running block!')

  {
    echo ❌ $actual-description
    echo $capture-result[output]
    echo ❌❌❌
  } >&2

  fail $capture-result[exception]
}