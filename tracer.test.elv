use ./command
use ./fs
use ./tracer
use ./writer

fn run-tests-for-tracer { |tracer stream|
  fn assert-tracer-data { |block expected-data|
    command:capture &stream=$stream $block |
      put (all)[data] |
      should-be $expected-data
  }

  >> 'echo' {
    assert-tracer-data {
      $tracer[echo] YOGI
    } [
      YOGI
    ]
  }

  >> 'print' {
    assert-tracer-data {
      $tracer[print] YOGI
    } [
      YOGI
    ]
  }

  >> 'printf' {
    var base = Dodo
    var value = 90

    assert-tracer-data {
      $tracer[printf] &newline '%s: %s' $base $value
    } [
      $base': '$value
    ]
  }

  >> 'pprint' {
    assert-tracer-data {
      $tracer[pprint] [ A B C ]
    } [
        '['
        ' A'
        ' B'
        ' C'
        ']'
      ]
  }

  >> 'inspect' {
    assert-tracer-data {
      $tracer[inspect] Map [ &x=90 &y=92 ]
    } [
      '🔎 Map: ['
      " &x=\t90"
      " &y=\t92"
      ']'
    ]
  }

  >> 'inspect-input-map' {
    assert-tracer-data {
      $tracer[inspect-input-map] [&a=90 &b=dodo]
    } [
      '📥 Input map: ['
      " &a=\t90"
      " &b=\tdodo"
      ']'
    ]
  }

  >> 'section' {
    >> 'with string' {
      assert-tracer-data {
        $tracer[section] &emoji=📚 'Description' "Some\ntext"
      } [
        '📚 Description:'
        Some
        text
        📚📚📚
      ]
    }

    >> 'with block' {
      assert-tracer-data {
        $tracer[section] &emoji=📚 'Description' {
          echo Alpha
          echo Beta
          $tracer[inspect] Gamma (num 92)
        }
      } [
        '📚 Description:'
        Alpha
        Beta
        '🔎 Gamma: (num 92)'
        📚📚📚
      ]
    }
  }
}

>> 'Tracer' {
  var scenarios = [
    [
      &stream=out
      &writer=$writer:out
    ]
    [
      &stream=err
      &writer=$writer:err
    ]
  ]

  all $scenarios | each { |scenario|
    var stream = $scenario[stream]
    var writer = $scenario[writer]

    >> 'when writing to '$stream {
      >> 'when enabled state is based on a variable' {
        var tracer = (tracer:create $true &writer=$writer)

        run-tests-for-tracer $tracer $stream
      }

      >> 'when enabled state is based on a block' {
        var tracer = (tracer:create { put $true } &writer=$writer)

        run-tests-for-tracer $tracer $stream
      }
    }
  }

  >> 'when writing to a file' {
    fs:with-temp-file { |temp-path|
      var writer = (writer:to-file $temp-path)

      var tracer = (tracer:create $true &writer=$writer)

      $tracer[echo] Dodo
      $tracer[section] &emoji=🧭 'Basic test' {
        $tracer[print] 'Hello, '
        $tracer[echo] world
        $tracer[pprint] [90 92]
      }

      from-lines < $temp-path |
        should-emit [
          Dodo
         '🧭 Basic test:'
         'Hello, world'
         '['
         ' 90'
         ' 92'
         ']'
         🧭🧭🧭
        ]
    }
  }
}