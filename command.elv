use os
use ./console
use ./fs
use ./map

fn exists-in-bash { |command|
  eq $ok ?(bash -c 'type '$command > $os:dev-null 2>&1)
}

#TODO! Test this!
fn take-bytes { |&keep-stream=both block|
  var redirected-block = (map:get-value [
    &both={ $block 2>&1 }

    &out={ $block 2>$os:dev-null }

    &err={ $block 2>&1 >$os:dev-null }

    &none={ $block >$os:dev-null 2>&1 }
  ] $keep-stream &default={ fail 'Invalid stream value: '$keep-stream  })

  $redirected-block | only-bytes | slurp
}

#TODO! Update its tests
fn capture { |&keep-stream=both block|
  var status = $ok

  var output = (
    take-bytes &keep-stream=$keep-stream {
      try {
        $block
      } catch e {
        set status = $e
      }
    }
  )

  put [
    &status=$status
    &output=$output
  ]
}

fn silence { |block|
  take-bytes &keep-stream=none $block
}

fn silence-until-error { |&description=$nil block|
  var capture-result = (capture $block)

  if (eq $capture-result[status] $ok) {
    return
  }

  var actual-description = (coalesce $description 'Error while running command block!')

  console:section &emoji=❌ $actual-description {
    echo $capture-result[output]
  }

  fail $capture-result[status]
}