use ./command
use ./console

fn assert-console-output { |block expected|
  command:capture &keep-stream=err $block |
    put (all)[output] |
    should-be $expected
}

>> 'In console module' {
  >> 'echo' {
    var message = 'Dodo'

    assert-console-output {
      console:echo $message
    } $message"\n"
  }

  >> 'print' {
    var message = 'Dodo'

    assert-console-output {
      console:print $message
    } $message
  }

  >> 'printf' {
    >> 'when requesting newline' {
      var base = 'Dodo'
      var value = 90

      assert-console-output {
        console:printf &newline $base': %s' $value
      } $base': '$value"\n"
    }

    >> 'when not requesting newline' {
      var base = 'Dodo'
      var value = 90

      assert-console-output {
        console:printf $base': %s' $value
      } $base': '$value
    }
  }

  >> 'pprint' {
    assert-console-output {
      console:pprint [ A B C ]
    } "[\n A\n B\n C\n]\n"
  }

  >> 'inspect' {
    >> 'with a string' {
      >> 'having one word' {
        assert-console-output {
          console:inspect String A
        }  "🔎 String: A\n"
      }

      >> 'having multiple words' {
        assert-console-output {
          console:inspect String 'Alpha Beta'
        }  "🔎 String: 'Alpha Beta'\n"
      }
    }

    >> 'with a number' {
      >> 'should print the raw value' {
        assert-console-output {
          console:inspect Number (num 98)
        } "🔎 Number: (num 98)\n"
      }
    }

    >> 'with a list' {
      >> 'should pretty-print' {
        assert-console-output {
          console:inspect List [ X Y Z ]
        } "🔎 List: [\n X\n Y\n Z\n]\n"
      }
    }

    >> 'with a map' {
      >> 'should pretty-print' {
        assert-console-output {
          console:inspect Map [ &x=90 &y=92 ]
        } "🔎 Map: [\n &x=\t90\n &y=\t92\n]\n"
      }
    }
  }

  >> 'inspecting input map' {
    >> 'should-work' {
      assert-console-output {
        console:inspect-inputs [&a=90 &b=dodo]
      } "📥 Input map: [\n &a=\t90\n &b=\tdodo\n]\n"
    }
  }

  >> 'section' {
    >> 'when a string is passed' {
      >> 'should print the string' {
        assert-console-output {
          console:section &emoji=📚 'Description' 'Test content'
        } "📚 Description:\nTest content\n📚📚📚\n"
      }
    }

    >> 'when a block is passed' {
      >> 'should print the block output' {
        assert-console-output {
          console:section &emoji=📚 'Description' {
            echo Alpha
            echo Beta
            console:inspect Gamma (num 92)
          }
        } "📚 Description:\nAlpha\nBeta\n🔎 Gamma: (num 92)\n📚📚📚\n"
      }
    }
  }
}