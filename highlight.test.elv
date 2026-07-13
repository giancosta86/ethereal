use ./highlight

>> 'In highlight module' {
  var code-line = 'fn main { }'

  >> 'when pygmentize is available' {
    var fake-intro = 'FAKING PYGMENTIZE'

    tmp highlight:-pygmentize = { |@arguments|
      echo $fake-intro

      to-lines
    }

    >> 'highlighting a stream' {
      {
        echo $code-line
      } |
        highlight:stream rust |
        should-emit [
          $fake-intro
          $code-line
        ]
    }

    >> 'highlighting a file' {
      fs:with-temp-file { |temp-file|
        echo $code-line > $temp-file

        highlight:file $temp-file rust |
          should-emit [
            $fake-intro
            $code-line
          ]
      }
    }
  }

  >> 'when pygmentize is not available' {
    tmp highlight:-pygmentize = $nil

    >> 'highlighting a stream' {
      {
        echo $code-line
      } |
        highlight:stream rust |
        should-be $code-line
    }

    >> 'highlighting a file' {
      fs:with-temp-file { |temp-file|
        echo $code-line > $temp-file

        highlight:file $temp-file rust |
          should-be $code-line
      }
    }
  }
}