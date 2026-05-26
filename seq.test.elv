use str
use ./seq

>> 'In seq module' {
  >> 'testing for emptiness' {
    >> 'when the source is a list' {
      >> 'when the list is empty' {
        seq:is-empty [] |
          should-be $true
      }

      >> 'when the list is non-empty' {
        seq:is-empty [A B C] |
          should-be $false
      }
    }

    >> 'when the source is a string' {
      >> 'when the string is empty' {
        seq:is-empty '' |
          should-be $true
      }

      >> 'when the string is non-empty' {
        seq:is-empty Hello |
          should-be $false
      }
    }

    >> 'when the source is a map' {
      >> 'when the map is empty' {
        seq:is-empty [&] |
          should-be $true
      }

      >> 'when the map is non-empty' {
        seq:is-empty [&A=90] |
          should-be $false
      }
    }
  }

  >> 'testing for non-emptiness' {
    >> 'when the source is a list' {
      >> 'when the list is empty' {
        seq:is-non-empty [] |
          should-be $false
      }

      >> 'when the list is non-empty' {
        seq:is-non-empty [A B C] |
          should-be $true
      }
    }

    >> 'when the source is a string' {
      >> 'when the string is empty' {
        seq:is-non-empty '' |
          should-be $false
      }

      >> 'when the string is non-empty' {
        seq:is-non-empty World |
          should-be $true
      }
    }

    >> 'when the source is a map' {
      >> 'when the map is empty' {
        seq:is-non-empty [&] |
          should-be $false
      }

      >> 'when the map is non-empty' {
        seq:is-non-empty [&A=90] |
          should-be $true
      }
    }
  }

  >> 'enumerating' {
    >> 'when the sequence is empty' {
      all [] |
        seq:enumerate |
        should-emit []
    }

    >> 'when the sequence is non-empty' {
      >> 'when passing the sequence as arguments' {
        seq:enumerate A B C |
          should-emit [
            [0 A]
            [1 B]
            [2 C]
          ]
      }

      >> 'when passing the sequence via pipe' {
        all [A B C] |
          seq:enumerate |
          should-emit [
            [0 A]
            [1 B]
            [2 C]
          ]
      }
    }

    >> 'when passing the first index' {
      all [A B C] |
        seq:enumerate &start-index=35 |
        should-emit [
          [35 A]
          [36 B]
          [37 C]
        ]
    }
  }

  >> 'spreading each sub-sequence as a function arguments' {
    >> 'when the sequence is empty' {
      all [] |
        seq:spread { |a b| fail 'THIS SHOULD NOT RUN' } |
        should-emit []
    }

    >> 'when there are sub-sequences' {
      all [[a b 90] [x y 92]] |
        seq:spread { |left right result|
          put $left'+'$right'='$result
        } |
        should-emit [
          a+b=90
          x+y=92
        ]
    }
  }

  >> 'reduction' {
    >> 'when the sequence is empty' {
      all [] |
        seq:reduce 0 $'+~' |
        should-be 0
    }

    >> 'when the sequence has one item' {
      all [92] |
        seq:reduce 0 $'-~' |
        should-be -92
    }

    >> 'when the sequence has two items' {
      all [82 13] |
        seq:reduce 0 $'+~' |
        should-be 95
    }

    >> 'when the sequence has three items' {
      all [65 25 8] |
        seq:reduce 0 $'+~' |
        should-be 98
    }

    >> 'when the sequence has three items and a non-zero initial value' {
      all [65 25 8] |
        seq:reduce 4000 $'+~' |
        should-be 4098
    }

    >> 'should support break' {
      all [65 25 8] |
        seq:reduce 0 { |left right|
          if (eq $right 8) {
            break
          }

          + $left $right
        } |
        should-be 90
    }

    >> 'should support continue' {
      all [65 25 8 5] |
        seq:reduce 0 { |left right|
          if (eq $right 8) {
            continue
          }

          + $left $right
        } |
        should-be 95
    }

    >> 'when debug is requested' {
      all [65 25 8] |
        seq:reduce &debug 0 $'+~' |
        should-be 98
    }
  }

  >> 'getting the shared prefix of two sequences' {
    >> 'when the sequences are both empty' {
      >> 'should output an empty list' {
        seq:get-prefix [] [] |
          should-be []
      }
    }

    >> 'when the sequences are equal' {
      >> 'should output such sequence' {
        seq:get-prefix [A B C] [A B C] |
          should-be [A B C]
      }
    }

    >> 'when one is the prefix of the other' {
      >> 'when the left operand is shorter' {
        >> 'should output such operand' {
          seq:get-prefix [A B C] [A B C D E F] |
            should-be [A B C]
        }
      }

      >> 'when the right operand is shorter' {
        >> 'should output such operand' {
          seq:get-prefix [A B C D E F] [A B C] |
            should-be [A B C]
        }
      }
    }

    >> 'when the two sequences only partially overlap' {
      >> 'should output the shared prefix' {
        seq:get-prefix [A B C D M N O S T] [A B C S T] |
          should-be [A B C]
      }
    }
  }

  >> 'converting an empty sequence to default' {
    >> 'for strings' {
      >> 'when empty' {
        >> 'when not passing a default value' {
          put '' |
            seq:empty-to-default |
            should-be $nil
        }

        >> 'when passing a default value' {
          put '' |
            seq:empty-to-default &default=Dodo |
            should-be Dodo
        }
      }

      >> 'when not empty' {
        put Yogi |
          seq:empty-to-default |
          should-be Yogi
      }
    }

    >> 'for lists' {
      >> 'when empty' {
        >> 'when not passing a default value' {
          put [] |
            seq:empty-to-default |
            should-be $nil
        }

        >> 'when passing a default value' {
          put [] |
            seq:empty-to-default &default=[Cip Ciop] |
            should-be [Cip Ciop]
        }
      }

      >> 'when not empty' {
        put [90 92 95] |
          seq:empty-to-default |
          should-be [90 92 95]
      }
    }

    >> 'for maps' {
      >> 'when empty' {
        >> 'when not passing a default value' {
          put [&] |
            seq:empty-to-default |
            should-be $nil
        }

        >> 'when passing a default value' {
          put [&] |
            seq:empty-to-default &default=[&alpha=90] |
            should-be [&alpha=90]
        }
      }

      >> 'when not empty' {
        put [&omega=98] |
          seq:empty-to-default |
          should-be [&omega=98]
      }
    }
  }

  >> 'drilling down a sequence' {
    >> 'when the source is a multi-level map' {
      var test-map = [
        &a=[
          &b=[
            &c=90
          ]
        ]
      ]

      >> 'when no keys are passed' {
        >> 'should return the source map itself' {
          seq:drill-down $test-map |
            should-be $test-map
        }
      }

      >> 'when a partial path is passed' {
        >> 'should return a submap' {
          seq:drill-down $test-map a b |
            should-be [
              &c=90
            ]
        }
      }

      >> 'when an existing full path is passed' {
        >> 'should return the associated leaf value' {
          seq:drill-down $test-map a b c |
            should-be 90
        }
      }

      >> 'when the path does not exist' {
        >> 'if a default value is passed' {
          >> 'should return the default value' {
            var test-default = 'Some default value'

            seq:drill-down &default=$test-default $test-map a INEXISTENT c |
              should-be $test-default
          }
        }

        >> 'if no default value is passed' {
          >> 'should return $nil' {
            seq:drill-down $test-map a INEXISTENT c |
              should-be $nil
          }
        }
      }
    }

    >> 'when the source is a multi-level list' {
      var test-list = [
        90
        92
        [
          95
          [
            98
          ]
        ]
      ]

      >> 'when no keys are passed' {
        >> 'should return the source list itself' {
          seq:drill-down $test-list |
            should-be $test-list
        }
      }

      >> 'when a partial path is passed' {
        >> 'should return a sublist' {
          seq:drill-down $test-list 2 1 |
            should-be [
              98
            ]
        }
      }

      >> 'when an existing full path is passed' {
        >> 'should return the associated leaf value' {
          seq:drill-down $test-list 2 1 0 |
            should-be 98
        }
      }

      >> 'when the path does not exist' {
        >> 'if a default value is passed' {
          >> 'should return the default value' {
            var test-default = 'Some default value'

            seq:drill-down &default=$test-default $test-list 0 9999 0 |
              should-be $test-default
          }
        }

        >> 'if no default value is passed' {
          >> 'should return $nil' {
            seq:drill-down $test-list 0 9999 0 |
              should-be $nil
          }
        }
      }
    }
  }

  >> 'splitting by chunk count' {
    >> 'when chunk count < 0' {
      fails {
        all [Alpha Beta] |
          seq:split-by-chunk-count -1
      } |
        should-contain 'The chunk count must be > 0!'
    }

    >> 'when chunk count is 0' {
      fails {
        all [Alpha Beta] |
          seq:split-by-chunk-count 0
      } |
        should-contain 'The chunk count must be > 0!'
    }

    >> 'when performing round-robin allocation' {
      >> 'should support 1 chunk and 4 items' {
        all [Alpha Beta Gamma Delta] |
          seq:split-by-chunk-count 1 |
          should-emit [
            [Alpha Beta Gamma Delta]
          ]
      }

      >> 'with 3 chunks' {
        >> 'should support 0 items' {
          all [] |
            seq:split-by-chunk-count 3 |
            should-emit []
        }

        >> 'should support 1 item' {
          all [Alpha] |
            seq:split-by-chunk-count 3 |
            should-emit [
              [Alpha]
            ]
        }

        >> 'should support 2 items' {
          all [Alpha Beta] |
            seq:split-by-chunk-count 3 |
            should-emit [
              [Alpha]
              [Beta]
            ]
        }

        >> 'should support 3 items' {
          all [Alpha Beta Gamma] |
            seq:split-by-chunk-count 3 |
            should-emit [
              [Alpha]
              [Beta]
              [Gamma]
            ]
        }

        >> 'should support 4 items' {
          all [Alpha Beta Gamma Delta] |
            seq:split-by-chunk-count 3 |
            should-emit [
              [Alpha Delta]
              [Beta]
              [Gamma]
            ]
        }

        >> 'should support 7 items' {
          all [Alpha Beta Gamma Delta Epsilon Zeta Eta] |
            seq:split-by-chunk-count 3 |
            should-emit [
              [Alpha Delta Eta]
              [Beta Epsilon]
              [Gamma Zeta]
            ]
        }
      }
    }
  }

  >> 'when performing fast, sequential allocation' {
    >> 'should emit sequential segments' {
      range 65 (+ 65 26) |
        each $str:from-codepoints~ |
        seq:split-by-chunk-count &fast 7 |
        should-emit [
          [A B C D]
          [E F G H]
          [I J K L]
          [M N O P]
          [Q R S T]
          [U V W X]
          [Y Z]
        ]
    }

    >> 'should support 0 items' {
      all [] |
        seq:split-by-chunk-count &fast 7 |
        should-emit []
    }
  }

  >> 'converting a single value to list' {
    all [
      [
        &value-type=string
        &value=Dodo
      ]
      [
        &value-type=number
        &value=(num 90)
      ]
      [
        &value-type=exception
        &value=?(fail DODO)
      ]
    ] | each { |scenario|
      >> 'when the value is of type '$scenario[value-type] {
        seq:value-as-list $scenario[value] |
          should-be [
            $scenario[value]
          ]
      }
    }

    >> 'when the value is $nil' {
      seq:value-as-list $nil |
        should-be []
    }
  }

  >> 'splitting into equivalence classes' {
    >> 'with no items' {
      all [] |
        seq:equivalence-classes |
        should-emit []
    }

    >> 'with distinct items' {
      all [90 92 95 98] |
        seq:equivalence-classes |
        order &key={ |equivalence-class| put $equivalence-class[0] } |
        should-emit [
          [90]
          [92]
          [95]
          [98]
        ]
    }

    >> 'with equivalent items' {
      all [90 92 90 92 95 98 95 90 95] |
        seq:equivalence-classes |
        order &key={ |equivalence-class| put $equivalence-class[0] } |
        should-emit [
          [90 90 90]
          [92 92]
          [95 95 95]
          [98]
        ]
    }

    >> 'with custom equality' {
      all [
        Beta
        Dodo
        Alpha
        Ciop
        Sigma
        Testing
        Yogi
      ] |
        seq:equivalence-classes &equality={ |left right| eq (count $left) (count $right) } |
        order &key={ |equivalence-class| put $equivalence-class[0] } |
        should-emit [
          [Alpha Sigma]
          [Beta Dodo Ciop Yogi]
          [Testing]
        ]
    }
  }

  >> 'associating only substantial values' {
    var test-source = [&x=90]

    fn should-have-no-effect-with { |key value|
      seq:assoc-substantial $test-source $key $value |
        should-be $test-source
    }

    fn should-associate { |key value|
      seq:assoc-substantial $test-source $key $value |
        should-be &strict [
          &x=90
          &$key=$value
        ]
    }

    >> 'when associating $nil' {
      should-have-no-effect-with k $nil
    }

    >> 'when associating a number' {
      should-associate k (num 98)
    }

    >> 'when associating a string' {
      >> 'when empty' {
        should-have-no-effect-with k ''
      }

      >> 'when non-empty' {
        should-associate k Hello
      }
    }

    >> 'when associating a list' {
      >> 'when empty' {
        should-have-no-effect-with k []
      }

      >> 'when non-empty' {
        should-associate k [92]
      }
    }

    >> 'when associating a map' {
      >> 'when empty' {
        should-have-no-effect-with k [&]
      }

      >> 'when non-empty' {
        should-associate k [&sub-key=95]
      }
    }
  }

  >> 'converting to map' {
    >> 'with empty list' {
      seq:to-map [] { fail 'THIS SHOULD NOT RUN' } |
        should-be [&]
    }

    >> 'with empty string' {
      seq:to-map '' { fail 'THIS SHOULD NOT RUN' } |
        should-be [&]
    }

    >> 'with non-empty list' {
      seq:to-map [3 5 7] { |item| put 'X'(* $item 10) } |
        should-be [
          &X30=3
          &X50=5
          &X70=7
        ]
    }

    >> 'with non-empty string' {
      seq:to-map 'ABC' { |letter| put $letter$letter } |
        should-be [
          &AA=A
          &BB=B
          &CC=C
        ]
    }

    >> 'with duplicated items' {
      seq:to-map [R S R X R X Y Z] { |letter| put $letter'-once-only' } |
        should-be [
          &R-once-only=R
          &S-once-only=S
          &X-once-only=X
          &Y-once-only=Y
          &Z-once-only=Z
        ]
    }

    >> 'passing no items via pipe' {
      all [] |
        seq:to-map { fail 'THIS SHOULD NOT RUN' } |
        should-be [&]
    }

    >> 'passing items via pipe' {
      all [90 92 98] |
        seq:to-map { |item| * $item 10 } |
        should-be [
          &900=90
          &920=92
          &980=98
        ]
    }
  }

  >> 'making a getter' {
    >> 'when applied to a map' {
      var test-map = [
        &alpha=[
          &beta=[
            &gamma=90
          ]
        ]
      ]

      >> 'when no keys are passed' {
        (seq:make-getter) $test-map |
          should-be $test-map
      }

      >> 'when 1 key is passed' {
        (seq:make-getter alpha) $test-map |
          should-be $test-map[alpha]
      }

      >> 'when 2 keys are passed' {
        (seq:make-getter alpha beta) $test-map |
          should-be $test-map[alpha][beta]
      }

      >> 'when 3 keys are passed' {
        (seq:make-getter alpha beta gamma) $test-map |
          should-be $test-map[alpha][beta][gamma]
      }

      >> 'when a missing key is passed at any level' {
        throws {
         (seq:make-getter alpha MISSING gamma) $test-map
        } |
          exception:get-reason |
          to-string (all) |
          should-contain MISSING
      }
    }

    >> 'when applied to a list' {
      var test-list = [
        90
        [
          92
          95
          [ 98 ]
        ]
      ]

      >> 'when no indexes are passed' {
        (seq:make-getter) $test-list |
          should-be $test-list
      }

      >> 'when 1 index is passed' {
        (seq:make-getter 1) $test-list |
          should-be $test-list[1]
      }

      >> 'when 2 indexes are passed' {
        (seq:make-getter 1 2) $test-list |
          should-be $test-list[1][2]
      }

      >> 'when 3 indexes are passed' {
        (seq:make-getter 1 2 0) $test-list |
          should-be $test-list[1][2][0]
      }
    }
  }
}