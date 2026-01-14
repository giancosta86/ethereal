use str
use ./seq

>> 'In seq module' {
  >> 'testing for emptiness' {
    >> 'when the source is a list' {
      >> 'when the list is empty' {
        >> 'should output $true' {
          seq:is-empty [] |
            should-be $true
        }
      }

      >> 'when the list is non-empty' {
        >> 'should output $false' {
          seq:is-empty [A B C] |
            should-be $false
        }
      }
    }

    >> 'when the source is a string' {
      >> 'when the string is empty' {
        >> 'should output $true' {
          seq:is-empty '' |
            should-be $true
        }
      }

      >> 'when the string is non-empty' {
        >> 'should output $false' {
          seq:is-empty Hello |
            should-be $false
        }
      }
    }

    >> 'when the source is a map' {
      >> 'when the map is empty' {
        >> 'should output $true' {
          seq:is-empty [&] |
            should-be $true
        }
      }

      >> 'when the map is non-empty' {
        >> 'should output $false' {
          seq:is-empty [&A=90] |
            should-be $false
        }
      }
    }
  }

  >> 'testing for non-emptiness' {
    >> 'when the source is a list' {
      >> 'when the list is empty' {
        >> 'should output $false' {
          seq:is-non-empty [] |
            should-be $false
        }
      }

      >> 'when the list is non-empty' {
        >> 'should output $true' {
          seq:is-non-empty [A B C] |
            should-be $true
        }
      }
    }

    >> 'when the source is a string' {
      >> 'when the string is empty' {
        >> 'should output $false' {
          seq:is-non-empty '' |
            should-be $false
        }
      }

      >> 'when the string is non-empty' {
        >> 'should output $true' {
          seq:is-non-empty World |
            should-be $true
        }
      }
    }

    >> 'when the source is a map' {
      >> 'when the map is empty' {
        >> 'should output $false' {
          seq:is-non-empty [&] |
            should-be $false
        }
      }

      >> 'when the map is non-empty' {
        >> 'should output $true' {
          seq:is-non-empty [&A=90] |
            should-be $true
        }
      }
    }
  }

  >> 'enumerating' {
    >> 'when the sequence is empty' {
      >> 'when passing the sequence via pipe' {
        >> 'should emit nothing' {
          all [] |
            seq:enumerate |
            put [(all)] |
            should-be []
        }
      }
    }

    >> 'when the sequence is non-empty' {
      >> 'when passing the sequence as arguments' {
        seq:enumerate A B C |
          put [(all)] |
          should-be [
            [0 A]
            [1 B]
            [2 C]
          ]
      }

      >> 'when passing the sequence via pipe' {
        all [A B C] |
          seq:enumerate |
          put [(all)] |
          should-be [
            [0 A]
            [1 B]
            [2 C]
          ]
      }
    }

    >> 'when passing the first index' {
      >> 'should start from the given index' {
        all [A B C] |
          seq:enumerate &start-index=35 |
          put [(all)] |
          should-be [
            [35 A]
            [36 B]
            [37 C]
          ]
      }
    }
  }

  >> 'spreading each item as consumer arguments' {
    >> 'when the sequence is empty' {
      >> 'should not call the consumer' {
        all [] |
          seq:spread { |a b| fail 'THIS SHOULD NOT RUN' }
      }
    }

    >> 'when there are items' {
      >> 'should call the consumer for each item' {
        all [[a b 90] [x y 92]] |
          seq:spread { |left right result|
            put $left'+'$right'='$result
          } |
          put [(all)] |
          should-be [
            a+b=90
            x+y=92
          ]
      }
    }
  }

  >> 'reduction' {
    >> 'when the sequence is empty' {
      >> 'should return the initial value' {
        all [] |
          seq:reduce 0 $'+~' |
          should-be 0
      }
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

    >> 'when the sequence has three items and a different initial value' {
      all [65 25 8] |
        seq:reduce 4000 $'+~' |
        should-be 4098
    }

    >> 'should support break' {
      all [65 25 8] |
        seq:reduce 0 { |left right|
          if (==s $right 8) {
            break
          }

          + $left $right
        } |
        should-be 90
    }

    >> 'should support continue' {
      all [65 25 8 5] |
        seq:reduce 0 { |left right|
          if (==s $right 8) {
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

  >> 'coalescing an empty sequence' {
    >> 'for strings' {
      >> 'when empty' {
        >> 'when not passing a default value' {
          put '' |
            seq:coalesce-empty |
            should-be $nil
        }

        >> 'when passing a default value' {
          put '' |
            seq:coalesce-empty &default=Dodo |
            should-be Dodo
        }
      }

      >> 'when not empty' {
        put Yogi |
          seq:coalesce-empty |
          should-be Yogi
      }
    }

    >> 'for lists' {
      >> 'when empty' {
        >> 'when not passing a default value' {
          put [] |
            seq:coalesce-empty |
            should-be $nil
        }

        >> 'when passing a default value' {
          put [] |
            seq:coalesce-empty &default=[Cip Ciop] |
            should-be [Cip Ciop]
        }
      }

      >> 'when not empty' {
        put [90 92 95] |
          seq:coalesce-empty |
          should-be [90 92 95]
      }
    }

    >> 'for maps' {
      >> 'when empty' {
        >> 'when not passing a default value' {
          put [&] |
            seq:coalesce-empty |
            should-be $nil
        }

        >> 'when passing a default value' {
          put [&] |
            seq:coalesce-empty &default=[&alpha=90] |
            should-be [&alpha=90]
        }
      }

      >> 'when not empty' {
        put [&omega=98] |
          seq:coalesce-empty |
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
      >> 'should fail' {
        fails {
          all [Alpha Beta] |
            seq:split-by-chunk-count -1
        } |
          str:contains (all) 'The chunk count must be > 0' |
          should-be $true
      }
    }

    >> 'when chunk count is 0' {
      >> 'should fail' {
        fails {
          all [Alpha Beta] |
            seq:split-by-chunk-count 0
        } |
          str:contains (all) 'The chunk count must be > 0!' |
          should-be $true
      }
    }

    >> 'when performing round-robin allocation' {
      >> 'should support 1 chunk and 4 items' {
        all [Alpha Beta Gamma Delta] |
          seq:split-by-chunk-count 1 |
          put [(all)] |
          should-be [[Alpha Beta Gamma Delta]]
      }

      >> 'with 3 chunks' {
        >> 'should support 0 items' {
          all [] |
            seq:split-by-chunk-count 3 |
            put [(all)] |
            should-be []
        }

        >> 'should support 1 item' {
          all [Alpha] |
            seq:split-by-chunk-count 3 |
            put [(all)] |
            should-be [[Alpha]]
        }

        >> 'should support 2 items' {
          all [Alpha Beta] |
            seq:split-by-chunk-count 3 |
            put [(all)] |
            should-be [[Alpha] [Beta]]
        }

        >> 'should support 3 items' {
          all [Alpha Beta Gamma] |
            seq:split-by-chunk-count 3 |
            put [(all)] |
            should-be [[Alpha] [Beta] [Gamma]]
        }

        >> 'should support 4 items' {
          all [Alpha Beta Gamma Delta] |
            seq:split-by-chunk-count 3 |
            put [(all)] |
            should-be [[Alpha Delta] [Beta] [Gamma]]
        }

        >> 'should support 7 items' {
          all [Alpha Beta Gamma Delta Epsilon Zeta Eta] |
            seq:split-by-chunk-count 3 |
            put [(all)] |
            should-be [[Alpha Delta Eta] [Beta Epsilon] [Gamma Zeta]]
        }
      }
    }
  }

  >> 'when performing fast allocation' {
    >> 'should work' {
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
    >> 'when the value is a string' {
      >> 'should emit a list containing just the value' {
        seq:value-as-list Dodo |
          should-be [Dodo]
      }
    }

    >> 'when the value is a number' {
      >> 'should emit a list containing just the value' {
        seq:value-as-list (num 90) |
          should-be [(num 90)]
      }
    }

    >> 'when the value is an exception' {
      >> 'should emit a list containing just the value' {
        var value = ?(fail DODO)

        seq:value-as-list $value |
          should-be [$value]
      }
    }

    >> 'when the value is $nil' {
      >> 'should emit an empty list' {
        seq:value-as-list $nil |
          should-be []
      }
    }
  }

  >> 'splitting into equivalence classes' {
    >> 'with no items' {
      all [] |
        seq:equivalence-classes |
        put [(all)] |
        should-be []
    }

    >> 'with distinct items' {
      all [90 92 95 98] |
        seq:equivalence-classes |
        order &key={ |equivalence-class| put $equivalence-class[0] } |
        put [(all)] |
        should-be [
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
        put [(all)] |
        should-be [
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
        put [(all)] |
        should-be [
          [Alpha Sigma]
          [Beta Dodo Ciop Yogi]
          [Testing]
        ]
    }
  }
}