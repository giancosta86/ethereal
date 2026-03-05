use str
use ./lang

>> 'In lang module' {
  >> 'ternary selector' {
    >> 'when the condition is true' {
      lang:ternary $true 92 95 |
        should-be 92
    }

    >> 'when the condition is false' {
      lang:ternary $false 92 95 |
        should-be 95
    }

    >> 'should evaluate eagerly' {
      throws {
        lang:ternary $true [][90]
      } |
        to-string (all) |
        should-contain 'out of range'
    }

    >> 'when passing code blocks' {
      var block = (lang:ternary $true { put Left } { put Right })

      lang:is-function $block |
        should-be $true

      $block |
        should-be Left
    }
  }

  >> 'switch construct' {
    >> 'when the value has a matching case' {
      lang:switch 92 [
        &90={ put Hello }
        &92={ put World }
        &95={ put Test }
      ] |
        should-be World
    }

    >> 'when the value has no matching case' {
      >> 'when the default is declared' {
        lang:switch 90 [
          &92={ put Something }
        ] &default={ |value|
          + $value 100
        } |
          should-be 190
      }

      >> 'when the default is missing' {
        fails {
          lang:switch 90 [
            &92={ put Something }
          ]
        } |
          should-be 'Unexpected value in switch: 90'
      }
    }

    >> 'should be able to emit multiple values' {
      put 90 |
        lang:switch [
          &90={
            put Alpha
            put Beta
            put Gamma
          }
        ] |
          should-emit [
            Alpha
            Beta
            Gamma
          ]
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

    >> 'when multiple arguments are passed' {
      fails {
        lang:get-single-input [Alpha Beta]
      } |
        should-contain 'arity mismatch'
    }

    >> 'when multiple values are passed via pipe' {
      throws {
        put Alpha Beta |
          lang:get-single-input []
      } |
        to-string (all) |
        should-contain 'arity mismatch'
    }

    >> 'when both argument list and pipe values are passed' {
      put Alpha |
        lang:get-inputs [Ro] |
        should-be Ro
    }
  }

  >> 'getting multiple inputs' {
    >> 'when multiple arguments in argument list are passed' {
      lang:get-inputs [Alpha Beta] |
        should-emit [
          Alpha
          Beta
        ]
    }

    >> 'when multiple values are passed via pipe' {
      put Gamma Delta |
        lang:get-inputs [] |
        should-emit [
          Gamma
          Delta
        ]
    }

    >> 'when both argument list and pipe values are passed' {
      put Alpha Beta |
        lang:get-inputs [Ro Sigma] |
        should-emit [
          Ro
          Sigma
        ]
    }
  }

  >> 'function detector' {
    >> 'when passing a non-function value' {
      lang:is-function 98 |
        should-be $false
    }

    >> 'when passing a function' {
      fn my-function { echo Hello }

      lang:is-function $my-function~ |
        should-be $true
    }

    >> 'when passing a code block' {
      var code = { echo Hello }

      lang:is-function $code |
        should-be $true
    }
  }

  >> 'ensuring that a put is performed' {
    >> 'when a put is performed' {
      put Hello |
        lang:ensure-put &default=World |
        should-be Hello
    }

    >> 'when no value is received via pipe' {
      >> 'when the default value is not declared' {
        { } |
          lang:ensure-put |
          should-be $nil
      }

      >> 'when the default value is declared' {
        { } |
          lang:ensure-put &default=World |
          should-be World
      }
    }
  }

  >> 'flattening numbers' {
    >> 'for string' {
      lang:flat-num X |
        should-be &strict X
    }

    >> 'for number' {
      lang:flat-num (num 90) |
        should-be &strict 90
    }

    >> 'for boolean' {
      lang:flat-num $true |
        should-be &strict $true
    }

    >> 'for $nil' {
      lang:flat-num $nil |
        should-be &strict $nil
    }

    >> 'for exception' {
      var ex = ?(fail DODO)

      lang:flat-num $ex |
        should-be &strict $ex
    }

    >> 'for list' {
      lang:flat-num [
        Alpha
        (num 92)
        $nil
        $false
      ] |
        should-be &strict [
          Alpha
          92
          $nil
          $false
        ]
    }

    >> 'for multi-level list' {
      lang:flat-num [
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
      lang:flat-num [
        &alpha=(num 90)
        &(num 92)=beta
      ] |
        should-be &strict [
          &alpha=90
          &92=beta
        ]
    }

    >> 'for multi-level map' {
      lang:flat-num [
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

  >> 'resolving a value' {
    >> 'if the value is a not a function' {
      lang:resolve 90 |
        should-be 90
    }

    >> 'if the value is a function emitting one value' {
      fn f {
        put 90
      }

      put $f~ |
        lang:resolve |
        should-be 90
    }

    >> 'if the value is a block emitting one value' {
      lang:resolve {
        put 90
      } |
        should-be 90
    }

    >> 'if the value is a block emitting multiple values' {
      throws {
        lang:resolve {
          put 90
          put 97
        } |
          should-be 90
      } |
        to-string (all) |
        str:contains (all) 'arity mismatch' |
        should-be $true
    }
  }

  >> 'getting a value' {
    >> 'applied to a list' {
      >> 'when the index exists' {
        lang:get-value [A B C] 2 |
          should-be C
      }

      >> 'when the index does not exist' {
        >> 'when a default value is passed' {
          lang:get-value &default=Dodo [A B C] 90 |
            should-be Dodo
        }

        >> 'when no default value is passed' {
          lang:get-value [A B C] 90 |
            should-be $nil
        }
      }
    }

    >> 'applied to a map' {
      var map = [&a=98 &b=30]

      >> 'when the key exists' {
        put $map b |
          lang:get-value |
          should-be 30
      }

      >> 'when the key does not exist' {
        >> 'when the default value is not passed' {
          lang:get-value $map INEXISTING |
            should-be $nil
        }

        >> 'when the default value is passed' {
          lang:get-value $map INEXISTING &default=4321 |
            should-be 4321
        }
      }
    }
  }

  >> 'testing for a sequence' {
    >> 'applied to $nil' {
      lang:is-seq $nil |
        should-be $false
    }

    >> 'applied to a number' {
      lang:is-seq (num 90) |
        should-be $false
    }

    >> 'applied to a boolean' {
      lang:is-seq $true |
        should-be $false
    }

    >> 'applied to a string' {
      lang:is-seq Dodo |
        should-be $true
    }

    >> 'applied to a list' {
      lang:is-seq [90 92 95] |
        should-be $true
    }

    >> 'applied to a map' {
      lang:is-seq [&alpha=90 &beta=92] |
        should-be $true
    }
  }

  >> 'testing for substantial values' {
    >> 'when passing $nil' {
      lang:is-substantial $nil |
        should-be $false
    }

    >> 'when passing a string' {
      >> 'when non-empty' {
        lang:is-substantial 'Hello' |
          should-be $true
      }

      >> 'when empty' {
        lang:is-substantial '' |
          should-be $false
      }
    }

    >> 'when passing a list' {
      >> 'when non-empty' {
        lang:is-substantial [90 92] |
          should-be $true
      }

      >> 'when empty' {
        lang:is-substantial [] |
          should-be $false
      }
    }

    >> 'when passing a map' {
      >> 'when non-empty' {
        lang:is-substantial [&k=90] |
          should-be $true
      }

      >> 'when empty' {
        lang:is-substantial [&] |
          should-be $false
      }
    }

    >> 'when passing just a number' {
      lang:is-substantial (num 90) |
        should-be $true
    }

    >> 'when passing an exception' {
      lang:is-substantial ?(fail DODO) |
        should-be $true
    }
  }

  >> 'negating a function' {
    fn greater-than-ninety { |x| > $x 90 }

    >> 'should create a function returning the negated result' {
      var not-greater-than-ninety~ = (lang:negate $greater-than-ninety~)

      not-greater-than-ninety 2 |
        should-be $true

      not-greater-than-ninety 90 |
        should-be $true

      not-greater-than-ninety 92 |
        should-be $false
    }

    >> 'should create a function easily pluggable into a functional pipeline' {
      all [
        2
        90
        92
      ] |
        each (lang:negate $greater-than-ninety~) |
        should-emit [
          $true
          $true
          $false
        ]
    }
  }

  >> 'detecting an exception' {
    >> 'applied to number' {
      lang:is-exception 90 |
        should-be $false
    }

    >> 'applied to divide-by-zero error' {
      lang:is-exception ?(/ 8 0) |
        should-be $true
    }

    >> 'applied to fail' {
      lang:is-exception ?(fail DODO) |
        should-be $true
    }

    >> 'applied to return' {
      lang:is-exception ?(return) |
        should-be $true
    }
  }
}