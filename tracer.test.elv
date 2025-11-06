use ./command
use ./tracer

#TODO! This function and the one in console tests could be replaced by a dedicated test function that also checks for no exception
fn assert-tracer-output { |block expected|
  command:capture &keep-stream=err $block |
    put (all)[output] |
    should-be $expected
}

>> 'Tracer' {
  var test-tracer = (tracer:create { put $true })

  >> 'echo' {
    assert-tracer-output {
      $test-tracer[echo] YOGI
    } YOGI"\n"
  }

  >> 'print' {
    assert-tracer-output {
      $test-tracer[print] YOGI
    } YOGI
  }

  >> 'printf' {
    var base = 'Dodo'
    var value = 90

    assert-tracer-output {
      $test-tracer[printf] &newline $base': %s' $value
    } $base': '$value"\n"
  }

  >> 'pprint' {
    assert-tracer-output {
      $test-tracer[pprint] [ A B C ]
    } "[\n A\n B\n C\n]\n"
  }

  >> 'inspect' {
    assert-tracer-output {
      $test-tracer[inspect] Map [ &x=90 &y=92 ]
    } "🔎 Map: [\n &x=\t90\n &y=\t92\n]\n"
  }

  >> 'inspect-input-map' {
    assert-tracer-output {
      $test-tracer[inspect-input-map] [&a=90 &b=dodo]
    } "📥 Input map: [\n &a=\t90\n &b=\tdodo\n]\n"
  }

  >> 'section' {
    assert-tracer-output {
      $test-tracer[section] &emoji=📚 'Description' {
        echo Alpha
        echo Beta
        $test-tracer[inspect] Gamma (num 92)
      }
    } "📚 Description:\nAlpha\nBeta\n🔎 Gamma: (num 92)\n📚📚📚\n"
  }
}