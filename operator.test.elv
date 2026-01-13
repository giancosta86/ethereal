use ./operator

fn custom-binary-add { |left right|
  + $left $right
}

>> 'In operator module' {
  >> 'when creating a multi-value operator' {
    var custom-add~ = (operator:multi-value 0 $custom-binary-add~)

    >> 'when no operands are passed' {
      custom-add |
        should-be 0
    }

    >> 'when one operand is passed' {
      >> 'as argument' {
        custom-add 3 |
          should-be 3
      }

      >> 'via pipe' {
        all [3] |
          custom-add |
          should-be 3
      }
    }

    >> 'when two operands are passed' {
      >> 'as arguments' {
        custom-add 3 5 |
          should-be (+ 3 5)
      }

      >> 'via pipe' {
        all [3 5] |
          custom-add |
          should-be (+ 3 5)
      }
    }

    >> 'when three operands are passed' {
      >> 'as arguments' {
        custom-add 3 5 90 |
          should-be (+ 3 5 90)
      }

      >> 'via pipe' {
        all [3 5 90] |
          custom-add |
          should-be (+ 3 5 90)
      }
    }
  }
}