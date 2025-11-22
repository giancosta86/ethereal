use ./command
use ./tracer

fn assert-tracer-data { |block expected-data|
  command:capture &stream=err $block |
    put (all)[data] |
    should-be $expected-data
}

>> 'Tracer' {
  var test-tracer = (tracer:create { put $true })

  >> 'echo' {
    assert-tracer-data {
      $test-tracer[echo] YOGI
    } [
      YOGI
    ]
  }

  >> 'print' {
    assert-tracer-data {
      $test-tracer[print] YOGI
    } [
      YOGI
    ]
  }

  >> 'printf' {
    var base = 'Dodo'
    var value = 90

    assert-tracer-data {
      $test-tracer[printf] &newline $base': %s' $value
    } [
      $base': '$value
    ]
  }

  >> 'pprint' {
    assert-tracer-data {
      $test-tracer[pprint] [ A B C ]
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
      $test-tracer[inspect] Map [ &x=90 &y=92 ]
    } [
      '🔎 Map: ['
      " &x=\t90"
      " &y=\t92"
      ']'
    ]
  }

  >> 'inspect-input-map' {
    assert-tracer-data {
      $test-tracer[inspect-input-map] [&a=90 &b=dodo]
    } [
      '📥 Input map: ['
      " &a=\t90"
      " &b=\tdodo"
      ']'
    ]
  }

  >> 'section' {
    assert-tracer-data {
      $test-tracer[section] &emoji=📚 'Description' {
        echo Alpha
        echo Beta
        $test-tracer[inspect] Gamma (num 92)
      }
    } [
      '📚 Description:'
      'Alpha'
      'Beta'
      '🔎 Gamma: (num 92)'
      📚📚📚
    ]
  }
}