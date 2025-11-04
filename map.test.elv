use ./map

>> 'In map module' {
  >> 'getting a value from a map' {
    var map = [&a=98 &b=30]

    >> 'when the key exists' {
      >> 'should return the related value' {
        map:get-value $map b |
          should-be 30
      }
    }

    >> 'when the key does not exist' {
      >> 'when the default value is not passed' {
        >> 'should return $nil' {
          map:get-value $map INEXISTING |
            should-be $nil
        }
      }

      >> 'when the default value is passed' {
        >> 'should return the default value' {
          map:get-value $map INEXISTING &default=4321 |
            should-be 4321
        }
      }
    }
  }

  >> 'getting the entries of a map' {
    >> 'when the map is empty' {
      >> 'should output nothing' {
        put [(map:entries [&])] |
          should-be []
      }
    }

    >> 'when the map has entries' {
      >> 'should output each of them' {
        put [(map:entries [&a=90 &b=92 &c=95])] |
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
      >> 'should have keys from the rightmost map' {
        map:merge [&a=90 &b=92] [&c=95 &a=89] [&a=3 &c=32] |
          should-be [&a=3 &b=92 &c=32]
      }
    }

    >> 'when passing the maps via pipe' {
      >> 'should merge them' {
        put [&a=90 &b=92] [&c=95 &a=89] [&a=3 &c=32] |
          map:merge |
          should-be [&a=3 &b=92 &c=32]
      }
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

    >> 'when the entire path exists' {
      >> 'should return the value' {
        map:drill-down $test-map a b c |
          should-be 90
      }
    }

    >> 'when an intermediate part does not exist' {
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

    >> 'when no path is passed' {
      >> 'should return the source itself' {
        map:drill-down $test-map |
          should-be $test-map
      }
    }
  }

  >> 'filtering a map' {
    >> 'should work' {
      var source = [
        &a=90
        &b=92
        &c=98
        &d=300
      ]

      map:filter $source { |key value|
        put (and (> $value 90) (!=s $key c))
      } |
        should-be [&b=92 &d=300]
    }
  }

  >> 'filter-mapping a map' {
    >> 'with empty map' {
      map:filter-map [&] { |key value|
        fail 'This should not be called'
      } |
        should-be [&]
    }

    >> 'with non-empty map' {
      map:filter-map [&90=Alpha &18=Beta] { |key value|
        put [(+ $key 3) $value''$value]
      } |
        should-be [
          &(num 93)=AlphaAlpha
          &(num 21)=BetaBeta
        ]
    }

    >> 'with filtering' {
      map:filter-map [
        &90=Alpha
        &18=Beta
        &72=Gamma
        &32=Delta
      ] { |key value|
        if (< $key 50) {
          put [(+ $key 3) $value'-'$value]
        } else {
          put $nil
        }
      } |
        should-be [
          &21=Beta-Beta
          &35=Delta-Delta
        ]
    }
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
