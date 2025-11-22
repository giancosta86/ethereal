use ./command
use ./console

fn assert-console-data { |block expected|
  command:capture &stream=err $block |
    put (all)[data] |
    should-be $expected
}

>> 'In console module' {
  >> 'echo' {
    var message = 'Dodo'

    assert-console-data {
      console:echo $message
    } [
      $message
    ]
  }

  >> 'print' {
    var message = 'Dodo'

    assert-console-data {
      console:print $message
    } [
      $message
    ]
  }

  >> 'printf' {
    >> 'when requesting newline' {
      var base = 'Dodo'
      var value = 90

      assert-console-data {
        console:printf &newline $base': %s' $value
      } [
        $base': '$value
      ]
    }

    >> 'when not requesting newline' {
      var base = 'Dodo'
      var value = 90

      assert-console-data {
        console:printf $base': %s' $value
      } [
        $base': '$value
      ]
    }
  }

  >> 'pprint' {
    assert-console-data {
      console:pprint [ A B C ]
    } [
      '['
      ' A'
      ' B'
      ' C'
      ']'
    ]
  }

  >> 'inspect' {
    >> 'with a string' {
      >> 'having one word' {
        assert-console-data {
          console:inspect String A
        } [
          '🔎 String: A'
        ]
      }

      >> 'having multiple words' {
        assert-console-data {
          console:inspect String 'Alpha Beta'
        } [
          '🔎 String: ''Alpha Beta'''
        ]
      }
    }

    >> 'with a number' {
      >> 'should print the raw value' {
        assert-console-data {
          console:inspect Number (num 98)
        } [
          '🔎 Number: (num 98)'
        ]
      }
    }

    >> 'with a list' {
      >> 'should pretty-print' {
        assert-console-data {
          console:inspect List [ X Y Z ]
        } [
          '🔎 List: ['
          ' X'
          ' Y'
          ' Z'
          ']'
        ]
      }
    }

    >> 'with a map' {
      >> 'should pretty-print' {
        assert-console-data {
          console:inspect Map [ &x=90 &y=92 ]
        } [
          '🔎 Map: ['
          " &x=\t90"
          " &y=\t92"
          ']'
        ]
      }
    }
  }

  >> 'inspecting input map' {
    >> 'should-work' {
      assert-console-data {
        console:inspect-input-map [&a=90 &b=dodo]
      } [
        '📥 Input map: ['
        " &a=\t90"
        " &b=\tdodo"
        ']'
      ]
    }
  }

  >> 'section' {
    >> 'when a string is passed' {
      >> 'should print the string' {
        assert-console-data {
          console:section &emoji=📚 'Description' 'Test content'
        } [
          '📚 Description:'
          'Test content'
          📚📚📚
        ]
      }
    }

    >> 'when a block is passed' {
      >> 'should print the block output' {
        assert-console-data {
          console:section &emoji=📚 'Description' {
            echo Alpha
            echo Beta
            console:inspect Gamma (num 92)
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
}