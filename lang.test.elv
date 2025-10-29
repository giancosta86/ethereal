use ./lang

>> 'In lang module' {
  >> 'function detector' {
    >> 'when passing a non-function value' {
      >> 'should output $false' {
        lang:is-function 98 |
          should-be $false
      }
    }

    >> 'when passing a function' {
      >> 'should output $true' {
        fn my-function { echo 'Hello' }

        lang:is-function $my-function~ |
          should-be $true
      }
    }

    >> 'when passing a code block' {
      >> 'should output $true' {
        var code = { echo 'Hello' }

        lang:is-function $code |
          should-be $true
      }
    }
  }

  >> 'ternary selector' {
    >> 'when the condition is true' {
      >> 'should return the left operand' {
        lang:ternary $true 92 95 |
          should-be 92
      }
    }

    >> 'when the condition is false' {
      >> 'should return the right operand' {
        lang:ternary $false 92 95 |
          should-be 95
      }
    }

    >> 'when passing code blocks' {
      >> 'should return a code block without executing it' {
        var block = (lang:ternary $true { put 'Left' } { put 'Right' })

        lang:is-function $block |
          should-be $true

        $block |
          should-be 'Left'
      }
    }
  }

  >> 'ensuring that a put is performed' {
    >> 'when a put is performed' {
      >> 'should just do nothing' {
        { put Hello } |
          lang:ensure-put &default=World |
          should-be Hello
      }
    }

    >> 'when no put is performed by the block' {
      >> 'should output the default value' {
        { } |
          lang:ensure-put &default=World |
          should-be World
      }
    }
  }
}