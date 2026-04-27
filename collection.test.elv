use github.com/giancosta86/ethereal/v1/set
use ./collection

>> 'Collections' {
  >> 'detecting kind' {
    >> 'for string' {
      collection:detect-kind Dodo |
        should-be string
    }

    >> 'for list' {
      collection:detect-kind [90 92] |
        should-be list
    }

    >> 'for map' {
      collection:detect-kind [&a=90] |
        should-be map
    }

    >> 'for set' {
      set:of 90 92 95 98 |
        collection:detect-kind |
        should-be ethereal-set
    }

    >> 'for boolean' {
      fails {
        collection:detect-kind $true
      } |
        should-be 'Data type not supported as a collection: bool'
    }
  }

  >> 'getting the value description' {
    >> 'for string' {
        collection:get-value-description Dodo |
        should-be substring
    }

    >> 'for list' {
      collection:get-value-description [] |
        should-be item
    }

    >> 'for map' {
      collection:get-value-description [&] |
        should-be key
    }

    >> 'for set' {
        put $set:empty |
          collection:get-value-description |
          should-be item
    }

    >> 'for number' {
      fails {
        collection:get-value-description (num 90)
      } |
        should-be 'Data type not supported as a collection: number'
    }
  }

  >> 'testing emptiness' {
    >> 'for string' {
      >> 'when empty' {
        collection:is-empty '' |
          should-be $true
      }

      >> 'when non-empty' {
        put Dodo |
          collection:is-empty |
          should-be $false
      }
    }

    >> 'for list' {
      >> 'when empty' {
        collection:is-empty [] |
          should-be $true
      }

      >> 'when non-empty' {
        put [90 92 95 98] |
          collection:is-empty |
          should-be $false
      }
    }

    >> 'for map' {
      >> 'when empty' {
        collection:is-empty [&] |
          should-be $true
      }

      >> 'when non-empty' {
        put [&a=90] |
          collection:is-empty |
          should-be $false
      }
    }

    >> 'for set' {
      >> 'when empty' {
        collection:is-empty $set:empty |
          should-be $true
      }

      >> 'when non-empty' {
        set:of 90 92 95 |
          collection:is-empty |
          should-be $false
      }
    }
  }

  >> 'testing non-emptiness' {
    >> 'for string' {
      >> 'when empty' {
        collection:is-non-empty '' |
          should-be $false
      }

      >> 'when non-empty' {
        put Dodo |
          collection:is-non-empty |
          should-be $true
      }
    }

    >> 'for list' {
      >> 'when empty' {
        collection:is-non-empty [] |
          should-be $false
      }

      >> 'when non-empty' {
        put [90 92 95 98] |
          collection:is-non-empty |
          should-be $true
      }
    }

    >> 'for map' {
      >> 'when empty' {
        collection:is-non-empty [&] |
          should-be $false
      }

      >> 'when non-empty' {
        put [&a=92] |
          collection:is-non-empty |
          should-be $true
      }
    }

    >> 'for set' {
      >> 'when empty' {
        collection:is-non-empty $set:empty |
          should-be $false
      }

      >> 'when non-empty' {
        set:of 90 92 95 98 |
          collection:is-non-empty |
          should-be $true
      }
    }
  }

  >> 'checking containment' {
    >> 'for string' {
      >> 'when the substring is contained' {
        collection:contains Dodo od |
          should-be $true
      }

      >> 'when the substring is not contained' {
        collection:contains Yogi Bubu |
          should-be $false
      }
    }

    >> 'for list' {
      >> 'when the item is contained' {
        put [90 92 95 98] |
          collection:contains 95 |
          should-be $true
      }

      >> 'when the item is not contained' {
        collection:contains [90 92 95 98] 73 |
          should-be $false
      }
    }

    >> 'for map' {
      >> 'when the key is contained' {
        put [&a=90 &b=92 &c=95] |
          collection:contains b |
          should-be $true
      }

      >> 'when the key is not contained' {
        collection:contains [&a=90 &b=92 &c=95] zod |
          should-be $false
      }
    }

    >> 'for set' {
      >> 'when the item is contained' {
        set:of 90 92 95 98 |
          collection:contains 92 |
          should-be $true
      }

      >> 'when the item is not contained' {
        set:of 90 92 95 98 |
          collection:contains 7 |
          should-be $false
      }
    }

    >> 'for number' {
      fails {
        collection:contains (num 90) 90
      } |
        should-be 'Data type not supported as a collection: number'
    }
  }

  >> 'Converting to list' {
    >> 'for string' {
      put Magic |
        collection:to-list |
        should-be [
          M
          a
          g
          i
          c
        ]
    }

    >> 'for list' {
      collection:to-list [90 92 95 98] |
        should-be [90 92 95 98]
    }

    >> 'for map' {
      put [
        &a=90
        &b=92
        &c=95
        &d=98
      ] |
        collection:to-list |
        all (all) |
        should-emit &any-order [
          a
          b
          c
          d
        ]
    }

    >> 'for set' {
      set:of a b c d |
        collection:to-list |
        all (all) |
        order &key=$to-string~ |
        should-emit [
          a
          b
          c
          d
        ]
    }

    >> 'for number' {
      fails {
        collection:to-list (num 90)
      } |
        should-be 'Data type not supported as a collection: number'
    }
  }
}