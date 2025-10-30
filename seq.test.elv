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
          seq:is-empty 'Hello' |
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
          seq:is-non-empty 'World' |
            should-be $true
        }
      }
    }
  }

  >> 'enumerating' {
    >> 'when the sequence is empty' {
      >> 'should not call the consumer' {
        all [] | seq:enumerate { |index value|
          fail 'This should not be run'
        }
      }
    }

    >> 'when the sequence is non-empty' {
      >> 'should iterate' {
        all [A B C] | seq:enumerate { |index value|
          put [🦋 $index $value]
        } |
          put [(all)] |
          should-be [[🦋 0 A] [🦋 1 B] [🦋 2 C]]
      }
    }

    >> 'when passing the first index' {
      >> 'should start from the given index' {
        all [A B C] | seq:enumerate &start-index=35 { |index value|
          put [🍺 $index $value]
        } |
          put [(all)] |
          should-be [[🍺 35 A] [🍺 36 B] [🍺 37 C]]
      }
    }
  }

  >> 'iterating and spreading each item as consumer arguments' {
    >> 'when the sequence is empty' {
      >> 'should not call the consumer' {
        all [] |
          seq:each-spread { |a b| fail 'THIS SHOULD NOT RUN' }
      }
    }

    >> 'when there are items' {
      >> 'should call the consumer' {
        all [[a b 90] [x y 92]] |
          seq:each-spread { |left right result|
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
      >> 'should apply the operator' {
        all [92] |
          seq:reduce 0 $'-~' |
          should-be -92
      }
    }

    >> 'when the sequence has two items' {
      >> 'should apply the operator' {
        all [82 13] |
          seq:reduce 0 $'+~' |
          should-be 95
      }
    }

    >> 'when the sequence has three items' {
      >> 'should apply the operator' {
        all [65 25 8] |
          seq:reduce 0 $'+~' |
          should-be 98
      }
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
  }

  >> 'getting a value at a given index' {
    >> 'when the index exists' {
      >> 'should output the related value' {
        seq:get-at [A B C] 2 |
          should-be C
      }
    }

    >> 'when the index does not exist' {
      >> 'when a default value is passed' {
        >> 'should output such default value' {
          seq:get-at &default=Dodo [A B C] 90 |
            should-be Dodo
        }
      }

      >> 'when no default value is passed' {
        >> 'should output $nil' {
          seq:get-at [A B C] 90 |
            should-be $nil
        }
      }
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

  >> 'turning an empty sequence to default' {
    >> 'when not passing a default value' {
      >> 'for strings' {
        >> 'when empty' {
          >> 'should output $nil' {
            seq:empty-to-default '' |
              should-be $nil
          }
        }

        >> 'when non-empty' {
          >> 'should output the collection itself' {
            seq:empty-to-default 'Dodo' |
              should-be 'Dodo'
          }
        }
      }

      >> 'for lists' {
        >> 'when empty' {
          >> 'should output $nil' {
            seq:empty-to-default [] |
              should-be $nil
          }
        }

        >> 'when non-empty' {
          >> 'should output the collection itself' {
            seq:empty-to-default [A B C] |
              should-be [A B C]
          }
        }
      }

      >> 'for maps' {
        >> 'when empty' {
          >> 'should output $nil' {
            seq:empty-to-default [&] |
              should-be $nil
          }
        }

        >> 'when non-empty' {
          >> 'should output the collection itself' {
            seq:empty-to-default [&A=90 &B=92] |
              should-be [&A=90 &B=92]
          }
        }
      }
    }

    >> 'when passing a default value' {
      >> 'when the source is empty' {
        >> 'should return the default value' {
          var test-default = my-default

          seq:empty-to-default &default=$test-default '' |
            should-be $test-default

          seq:empty-to-default &default=$test-default [] |
            should-be $test-default

          seq:empty-to-default &default=$test-default [&] |
            should-be $test-default
        }
      }

      >> 'when the source is non-empty' {
        >> 'should return the source' {
          var test-default = my-default

          seq:empty-to-default &default=$test-default DODO |
            should-be DODO

          seq:empty-to-default &default=$test-default [A B C] |
            should-be [A B C]

          seq:empty-to-default &default=$test-default [&A=90] |
            should-be [&A=90]
        }
      }
    }
  }

  >> 'splitting by chunk count' {
    >> 'when chunk count < 0' {
      >> 'should fail' {
        throws {
          all [Alpha Beta] |
            seq:split-by-chunk-count -1
        } |
          get-fail-content |
          str:contains (all) 'The chunk count must be > 0' |
          should-be $true
      }
    }

    >> 'when chunk count is 0' {
      >> 'should fail' {
        throws {
          all [Alpha Beta] |
            seq:split-by-chunk-count 0
        } |
          get-fail-content |
          str:contains (all) 'The chunk count must be > 0!' |
          should-be $true
      }
    }

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

  >> 'converting single value to list' {
    >> 'when the value is a string' {
      >> 'should return a list containing just the value' {
        seq:value-as-list Dodo |
          should-be [Dodo]
      }
    }

    >> 'when the value is a number' {
      >> 'should return a list containing just the value' {
        seq:value-as-list (num 90) |
          should-be [(num 90)]
      }
    }

    >> 'when the value is an exception' {
      >> 'should return a list containing just the value' {
        var value = ?(fail DODO)

        seq:value-as-list $value |
          should-be [$value]
      }
    }

    >> 'when the value is $nil' {
      >> 'should return an empty list' {
        seq:value-as-list $nil |
          should-be []
      }
    }
  }
}