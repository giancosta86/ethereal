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

  >> 'minimized value' {
    >> 'for string' {
      var value = 'This is a string!'

      lang:minimize $value |
        should-be &strict $value
    }

    >> 'for number' {
      lang:minimize (num 90) |
        should-be &strict '90'
    }

    >> 'for boolean' {
      lang:minimize $true |
        should-be &strict $true
    }

    >> 'for $nil' {
      lang:minimize $nil |
        should-be &strict $nil
    }

    >> 'for exception' {
      var ex = ?(fail DODO)

      lang:minimize $ex |
        should-be &strict $ex
    }

    >> 'for list' {
      lang:minimize [
        Alpha
        (num 92)
        $nil
        $false
      ] |
        should-be &strict [
          Alpha
          '92'
          $nil
          $false
        ]
    }

    >> 'for multi-level list' {
      lang:minimize [
        Alpha
        [
          Beta
          [Gamma (num 95) Delta]
        ]
        $nil
        $false
      ] |
        should-be &strict [
          Alpha
          [
            Beta
            [Gamma 95 Delta]
          ]
          $nil
          $false
        ]
    }

    >> 'for map' {
      lang:minimize [
        &alpha=(num 90)
        &(num 92)=beta
      ] |
        should-be &strict [
          &alpha=90
          &92=beta
        ]
    }

    >> 'for multi-level map' {
      lang:minimize [
        &[alpha $true (num 95)]=[
          gamma
          [(num 98) epsilon]
          [&ro=[$nil (num 99)]]
        ]
      ] |
        should-be &strict [
          &[alpha $true 95]=[
            gamma
            [98 epsilon]
            [&ro=[$nil 99]]
          ]
        ]
    }
  }
}