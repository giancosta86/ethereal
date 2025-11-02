use ./set

>> 'In set module' {
  >> 'creating from item enumeration' {
    >> 'when passing 1 item' {
      >> 'as argument' {
        set:of DODO |
          should-be [
            &-set-items=[&DODO=$true]
          ]
      }

      >> 'via pipe' {
        put DODO |
          set:of |
          should-be [
            &-set-items=[&DODO=$true]
          ]
      }
    }

    >> 'when passing multiple items' {
      >> 'as argument' {
        set:of 90 92 95 98 |
          should-be [
            &-set-items=[
              &90=$true
              &92=$true
              &95=$true
              &98=$true
            ]
          ]
      }

      >> 'via pipe' {
        put 90 92 95 98 |
          set:of |
          should-be [
            &-set-items=[
              &90=$true
              &92=$true
              &95=$true
              &98=$true
            ]
          ]
      }
    }
  }

  >> 'converting to list' {
    >> 'when the set is empty' {
      put $set:empty |
        set:to-list |
        should-be []
    }

    >> 'when the set contains a single item' {
      set:of 90 |
        set:to-list |
        should-be [90]
    }

    >> 'when the set contains multiple items' {
      set:of 90 92 95 98 |
        set:to-list |
        order |
        should-be [90 92 95 98]
    }
  }

  >> 'testing if an object is a set' {
    >> 'applied to list' {
      set:is-set [] |
        should-be $false
    }

    >> 'applied to a set' {
      set:of 90 92 |
        set:is-set |
        should-be $true
    }
  }

  >> 'converting from another sequence' {
    >> 'if the source is a list' {
      put [92 90 98 95] |
        set:from |
        set:to-list |
        order (all) |
        put [(all)] |
        should-be [90 92 95 98]
    }

    >> 'if the source is a set' {
      set:of 90 92 95 98 |
        set:from |
        set:to-list |
        order (all) |
        put [(all)] |
        should-be [90 92 95 98]
    }
  }

  >> 'testing for emptiness' {
    >> 'on empty set' {
      put $set:empty |
        set:is-empty |
        should-be $true
    }

    >> 'on non-empty set' {
      set:of 90 92 95 98 |
        set:is-empty |
        should-be $false
    }
  }

  >> 'testing for non-emptiness' {
    >> 'on empty set' {
      put $set:empty |
        set:is-non-empty |
        should-be $false
    }

    >> 'on non-empty set' {
      set:of 90 92 95 98 |
        set:is-non-empty |
        should-be $true
    }
  }

  >> 'counting the items' {
    >> 'for empty set' {
      set:count $set:empty |
        should-be 0
    }

    >> 'for non-empty set' {
      set:of 90 92 95 98 |
        set:count |
        should-be 4
    }
  }

  >> 'checking for value' {
    >> 'when the value is present' {
      put 92 |
        set:has-value (set:of 90 92 95) |
        should-be $true
    }

    >> 'when the value is missing' {
      set:has-value (set:of 90 92 95) 9999 |
        should-be $false
    }
  }

  >> 'adding a value' {
    >> 'when the value is missing' {
      var source = (set:of 90 92 95 98)

      put 99 |
        set:add $source |
        should-be (set:of 90 92 95 98 99)

      set:count $source |
        should-be 4
    }

    >> 'when the value is already present' {
      var source = (set:of 90 92 95 98)

      set:add $source 95 |
        should-be $source
    }

    >> 'when adding multiple values' {
      var source = (set:of 90)

      set:add $source 92 95 98 |
        should-be (set:of 90 92 95 98)
    }
  }

  >> 'removing a value' {
    >> 'when the value is present' {
      var source = (set:of 90 92 95 98 99)

      put 99 |
        set:remove $source |
        should-be (set:of 90 92 95 98)

      set:count $source |
        should-be 5
    }

    >> 'when the value is missing' {
      var source = (set:of 90 92 95 98 99)

      put DODO |
        set:remove $source |
        should-be $source
    }

    >> 'when removing multiple value' {
      var source = (set:of 90 92 95 98 99)

      put 90 95 99 |
        set:remove $source |
        should-be (set:of 92 98)
    }
  }

  >> 'set operations' {
    var alpha = (set:of 90 92 95 98)
    var beta = (set:of 31 56 90 95 103 220)
    var gamma = (set:of 92 95)

    >> 'union' {
      >> 'with no operands' {
        set:union |
          should-be $set:empty
      }

      >> 'with empty sets' {
        set:union $set:empty $set:empty |
          should-be $set:empty
      }

      >> 'with non-empty sets' {
        set:union $alpha $beta $gamma |
          should-be (set:of 31 56 90 92 95 98 103 220)
      }
    }

    >> 'intersection' {
      >> 'with no operands' {
        set:intersection |
          should-be $set:empty
      }

      >> 'with empty sets' {
        set:intersection $set:empty $set:empty |
          should-be $set:empty
      }

      >> 'with empty and non-empty set' {
        set:intersection $set:empty $alpha |
          should-be $set:empty
      }

      >> 'with two non-empty sets' {
        set:intersection $alpha $beta |
          should-be (set:of 90 95)
      }

      >> 'with three non-empty sets' {
        set:intersection $alpha $beta $gamma |
          should-be (set:of 95)
      }
    }

    >> 'difference' {
      >> 'with no operands' {
        set:difference |
          should-be $set:empty
      }

      >> 'with empty sets' {
        set:difference $set:empty $set:empty |
          should-be $set:empty
      }

      >> 'with empty and non-empty set' {
        set:difference $set:empty $alpha |
          should-be $set:empty
      }

      >> 'with non-empty and empty set' {
        put $alpha $set:empty |
          set:difference |
          should-be $alpha
      }

      >> 'with two non-empty sets' {
        set:difference $beta $alpha |
          should-be (set:of 31 56 103 220)
      }

      >> 'with three non-empty sets' {
        put $alpha $beta $gamma |
          set:difference |
          should-be (set:of 98)
      }
    }

    >> 'symmetric difference' {
      var left = (set:of A B J K L)
      var right = (set:of J K Q R S)

      >> 'with empty sets' {
        set:symmetric-difference $set:empty $set:empty |
          should-be $set:empty
      }

      >> 'with empty and non-empty set' {
        set:symmetric-difference $set:empty $left |
          should-be $left
      }

      >> 'with non-empty and empty set' {
        put $left $set:empty |
          set:symmetric-difference |
          should-be $left
      }

      >> 'with two non-empty sets' {
        set:symmetric-difference $left $right |
          should-be (set:of A B L Q R S)
      }

      >> 'with two non-empty sets, in reversed order' {
        set:symmetric-difference $right $left |
          should-be (set:of A B L Q R S)
      }
    }
  }
}
