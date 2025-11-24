use ./map

>> 'In map module' {
  >> 'getting the entries of a map' {
    >> 'when the map is empty' {
      >> 'should output nothing' {
        map:entries [&] |
          put [(all)] |
          should-be []
      }
    }

    >> 'when the map has entries' {
      >> 'should output each of them' {
        map:entries [&a=90 &b=92 &c=95] |
          put [(all)] |
          should-be [[a 90] [b 92] [c 95]]
      }
    }
  }

  >> 'getting the values of a map' {
    >> 'when the map is empty' {
      >> 'should return an empty list' {
        map:values [&] |
          put [(all)] |
          should-be []
      }
    }

    >> 'when the map has entries' {
      >> 'should return the values' {
        map:values [&X90=B &X92=T &X95=A &X98=S] |
          order |
          put [(all)] |
          should-be [A B S T]
      }
    }
  }

  >> 'merging maps' {
    >> 'when the maps are empty' {
      >> 'should return an empty map' {
        map:merge [&] [&] [&] |
          should-be [&]
      }
    }

    >> 'when the maps have no overlaps' {
      >> 'should return a map containing all the keys' {
        map:merge [&a=90 &b=92] [&c=95 &d=98] [&e=99] |
          should-be [&a=90 &b=92 &c=95 &d=98 &e=99]
      }
    }

    >> 'when the maps have overlapping keys' {
      >> 'should have keys from the latest map' {
        map:merge [&a=90 &b=92] [&c=95 &a=89] [&a=3 &c=32] |
          should-be [&a=3 &b=92 &c=32]
      }
    }

    >> 'when passing the maps via pipe' {
      put [&a=90 &b=92] [&c=95 &a=89] [&a=3 &c=32] |
        map:merge |
        should-be [&a=3 &b=92 &c=32]
    }
  }

  >> 'drilling down a map' {
    var test-map = [
      &a=[
        &b=[
          &c=90
        ]
      ]
    ]

    >> 'when no keys are passed' {
      >> 'should return the source map itself' {
        map:drill-down $test-map |
          should-be $test-map
      }
    }

    >> 'when a partial path is passed' {
      >> 'should return a submap' {
        map:drill-down $test-map a b |
          should-be [
            &c=90
          ]
      }
    }

    >> 'when an existing full path is passed' {
      >> 'should return the associated leaf value' {
        map:drill-down $test-map a b c |
          should-be 90
      }
    }

    >> 'when the path does not exist' {
      >> 'if a default value is passed' {
        >> 'should return the default value' {
          var test-default = 'Some default value'

          map:drill-down &default=$test-default $test-map a INEXISTENT c |
            should-be $test-default
        }
      }

      >> 'if no default value is passed' {
        >> 'should return $nil' {
          map:drill-down $test-map a INEXISTENT c |
            should-be $nil
        }
      }
    }
  }

  >> 'transforming a map' {
    >> 'with empty map' {
      map:transform [&] { |key value|
        fail 'This should not be called'
      } |
        should-be [&]
    }

    >> 'with non-empty map' {
      map:transform [
        &Alpha=90
        &Beta=18
      ] { |key value|
        put [$key''$key (+ $value 3)]
      } |
        should-be [
          &AlphaAlpha=(num 93)
          &BetaBeta=(num 21)
        ]
    }

    >> 'with filter-mapping' {
      map:transform [
        &Alpha=90
        &Beta=18
        &Gamma=72
        &Delta=32
      ] { |key value|
        if (< $value 50) {
          put [$key'-'$key (+ $value 3)]
        }
      } |
        should-be [
          &Beta-Beta=21
          &Delta-Delta=35
        ]
    }

    >> 'with multiple outputs per entry' {
      map:transform [
        &A=1
        &B=2
      ] { |key value|
        put [$key'X' $value]
        put [$key'Y' $value]
        put [$key'Z' $value]
      } |
        should-be [
          &AX=1
          &AY=1
          &AZ=1

          &BX=2
          &BY=2
          &BZ=2
        ]
    }
  }

  >> 'keeping items from a map' {
    var source = [
      &a=90
      &b=92
      &c=98
      &d=300
    ]

    map:keep-if $source { |key value|
      put (and (> $value 90) (not-eq $key c))
    } |
      should-be [&b=92 &d=300]
  }

  >> 'making multi-value map' {
    >> 'with no entries' {
      all [] |
        map:multi-value |
        should-be [&]
    }

    >> 'with entries having the same key' {
      all [
        [alpha 95]
        [alpha 90]
        [beta 92]
        [gamma 98]
        [alpha 99]
        [beta 72]
      ] |
        map:multi-value |
          should-be [
            &alpha=[95 90 99]
            &beta=[92 72]
            &gamma=[98]
          ]
    }
  }
}
