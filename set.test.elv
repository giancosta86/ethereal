use ./hash-set

fn should-be-list { |expected-list|
  hash-set:to-list |
    order |
    should-be $expected-list
}

describe 'Hash set' {
  describe 'empty creation' {
    it 'should work' {
      put (hash-set:empty) |
        should-be [&]
    }
  }

  describe 'creation from sequence' {
    describe 'when the sequence is empty' {
      it 'should work' {
        all [] |
          hash-set:from |
          keys (all) |
          count |
          should-be 0
      }
    }

    describe 'when the sequence has items' {
      it 'should work' {
        all [A B C] |
          hash-set:from |
          keys (all) |
          count |
          should-be 3
      }
    }
  }

  describe 'creation from enumeration' {
    describe 'when passing a single item' {
      it 'should work' {
        hash-set:of A |
          keys (all) |
          count |
          should-be 1
      }
    }

    describe 'when passing multiple items' {
      it 'should work' {
        hash-set:of A B C |
          keys (all) |
          count |
          should-be 3
      }
    }
  }

  describe 'contains' {
    describe 'when the item is in the set' {
      it 'should be $true' {
        hash-set:of A B C |
          hash-set:contains (all) A |
          should-be $true

        hash-set:of A B C |
          hash-set:contains (all) B |
          should-be $true

        hash-set:of A B C |
          hash-set:contains (all) C |
          should-be $true
      }
    }

    describe 'when the item is not in the set' {
      it 'should be $false' {
        hash-set:of A B C |
          hash-set:contains (all) OMEGA |
          should-be $false
      }
    }
  }

  describe 'is-empty' {
    describe 'for empty set' {
      it 'should be $true' {
        hash-set:is-empty (hash-set:empty) |
          should-be $true
      }
    }

   describe 'for non-empty set' {
      it 'should be $false' {
        hash-set:is-empty (hash-set:of A B) |
          should-be $false
      }
    }
  }

  describe 'is-non-empty' {
    describe 'for empty set' {
      it 'should be $false' {
        hash-set:is-non-empty (hash-set:empty) |
          should-be $false
      }
    }

   describe 'for non-empty set' {
      it 'should be $true' {
        hash-set:is-non-empty (hash-set:of S) |
          should-be $true
      }
    }
  }

  describe 'to-list' {
    describe 'for empty set' {
      it 'should work' {
        hash-set:empty |
          should-be-list []
      }
    }

    describe 'for non-empty set' {
      it 'should work' {
        hash-set:of Z A X B |
          should-be-list [A B X Z]
      }
    }
  }

  describe 'adding items' {
    describe 'when adding a single item' {
      it 'should work' {
        hash-set:of A B C |
          hash-set:add (all) S |
          should-be-list [A B C S]
      }
    }

    describe 'when adding multiple items' {
      it 'should work' {
        hash-set:of A B C |
          hash-set:add (all) S T |
          should-be-list [A B C S T]
      }
    }
  }

  describe 'removing items' {
    describe 'when removing a single item' {
      it 'should work' {
        hash-set:of A B C |
          hash-set:remove (all) B |
          should-be-list [A C]
      }
    }

    describe 'when removing multiple items' {
      it 'should work' {
        hash-set:of A B C |
          hash-set:remove (all) A C |
          should-be-list [B]
      }
    }
  }

  describe 'union' {
    describe 'with just one operand' {
      it 'should work' {
        hash-set:union (hash-set:of A B C) |
          should-be-list [A B C]
      }
    }

    describe 'with multiple operands' {
      it 'should work' {
        hash-set:union (hash-set:of A B C) (hash-set:of C D) (hash-set:of S T) |
          should-be-list [A B C D S T]
      }
    }
  }

  describe 'intersection' {
    describe 'with just one operand' {
      it 'should work' {
        hash-set:intersection (hash-set:of A B C) |
          should-be-list [A B C]
      }
    }

    describe 'with multiple operands' {
      it 'should work' {
        hash-set:intersection (hash-set:of A B C) (hash-set:of B C D) (hash-set:of A B C S T) |
          should-be-list [B C]
      }
    }
  }

  describe 'difference' {
    describe 'with just one operand' {
      it 'should work' {
        hash-set:difference (hash-set:of A B C) |
          should-be-list [A B C]
      }
    }

    describe 'with multiple operands' {
      it 'should work' {
        hash-set:difference (hash-set:of A B C D E S T Z) (hash-set:of A C OMEGA) (hash-set:of S T) |
          should-be-list [B D E Z]
      }
    }
  }

  describe 'symmetric difference' {
    it 'should work' {
      hash-set:symmetric-difference (hash-set:of A B C D E T) (hash-set:of A C S T Z) |
        should-be-list [B D E S Z]
    }
  }
}