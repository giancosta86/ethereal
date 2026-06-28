use ./console

>> 'In console module' {
  >> 'section' {
    >> 'when not passing emoji' {
      capture &lines {
        console:section 'My description' {
          echo Hello
          echo World
        }
      } |
        should-emit [
          '🔎 My description:'
          Hello
          World
          '🔎 🔎 🔎'
        ]
    }

    >> 'when passing emoji' {
      capture &lines {
        console:section &emoji=📚 'My description' {
          echo Hello
          echo World
        }
      } |
        should-emit [
          '📚 My description:'
          Hello
          World
          '📚 📚 📚'
        ]
    }
  }

  >> 'inspect' {
    >> 'when passing a string' {
      capture {
        console:inspect &emoji=🏷️ 'String value' 'Hello, world!'
      } |
        should-be '🏷️ String value: ''Hello, world!'''
    }

    >> 'when passing a number' {
      capture {
        console:inspect &emoji=🎲 'Numeric value' (num 90)
      } |
        should-be '🎲 Numeric value: 90'
    }

    >> 'when passing a bool' {
      capture {
        console:inspect &emoji=💡 'Boolean value' $true
      } |
        should-be '💡 Boolean value: $true'
    }

    >> 'when passing a list' {
      capture &lines {
        console:inspect &emoji=📜 'List value' [90 92 95 98]
      } |
        should-emit [
          '📜 List value:'
          '['
          ' 90'
          ' 92'
          ' 95'
          ' 98'
          ']'
        ]
    }

    >> 'when passing a map' {
      capture &lines {
        console:inspect &emoji=🔑 'Map value' [&a=90 &b=92]
      } |
        should-emit [
          '🔑 Map value:'
          '['
          " &a=\t90"
          " &b=\t92"
          ']'
        ]
    }

    >> 'when passing $nil' {
      capture {
        console:inspect &emoji=❓ 'nil value' $nil
      } |
        should-be '❓ nil value: $nil'
    }

    >> 'when passing an exception' {
      capture &lines {
        console:inspect &emoji=🐞 'Exception value' ?(fail DODO)
      } |
        take 2 |
        should-emit [
          '🐞 Exception value:'
          'Exception: DODO'
        ]
    }
  }
}