use str
use ./lang

>> 'In lang module' {
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

  >> 'getting single input' {
    >> 'when it is passed as argument list' {
      lang:get-single-input [Alpha] |
        should-be Alpha
    }

    >> 'when it is passed via pipe' {
      put Alpha |
        lang:get-single-input [] |
        should-be Alpha
    }

    >> 'when multiple args are passed' {
      >> 'should fail' {
        throws {
          lang:get-single-input [Alpha Beta]
        } |
          str:contains (all)[reason][content] 'arity mismatch'
      }
    }

    >> 'when multiple values are passed via pipe' {
      >> 'should fail' {
        throws {
          put Alpha Beta |
            lang:get-single-input []
        } |
          to-string (all) |
          str:contains (all) 'arity mismatch' |
          should-be $true
      }
    }
  }

  >> 'getting multiple inputs' {
    >> 'when multiple arguments in argument list are passed' {
      lang:get-inputs [Alpha Beta] |
        put [(all)] |
        should-be [Alpha Beta]
    }

    >> 'when multiple values are passed via pipe' {
      put Gamma Delta |
        lang:get-inputs [] |
        put [(all)] |
        should-be [Gamma Delta]
    }

    >> 'when both argument list and pipe values are passed' {
      >> 'pipe values are ignored' {
        put Alpha Beta |
          lang:get-inputs [Ro Sigma] |
          put [(all)] |
          should-be [Ro Sigma]
      }
    }
  }

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

  >> 'preventing output' {
    >> 'when output is bytes' {
      {
        echo Alpha
        echo Beta
        echo Gamma
      } |
        lang:no-output |
        put [(all)] |
        should-be []
    }

    >> 'when output is values' {
      {
        put Alpha
        put Beta
        put Gamma
      } |
        lang:no-output |
        put [(all)] |
        should-be []
    }

    >> 'when output is mixed' {
      {
        put Alpha
        echo Beta
        put Gamma
      } |
        lang:no-output |
        put [(all)] |
        should-be []
    }
  }
}