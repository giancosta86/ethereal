use str
use ./string

>> 'In string module' {
  >> 'prefixing lines' {
    >> 'by default' {
      >> 'with empty string' {
        put '' |
          string:prefix-lines '****' |
          should-be ''
      }

      >> 'with single text line' {
        put 'Alpha' |
          string:prefix-lines '****' |
          should-be '****Alpha'
      }

      >> 'with 2 text lines' {
          put "Alpha\nBeta" |
            string:prefix-lines '****' |
            put [(all)] |
            should-be [
              '****Alpha'
              '****Beta'
            ]
      }

      >> 'with 2 text lines and final empty line' {
        put "Alpha\nBeta\n" |
          string:prefix-lines '****' |
          put [(all)] |
          should-be [
            '****Alpha'
            '****Beta'
            ''
          ]
      }

      >> 'with 2 text lines and intermediate empty lines' {
        put "Alpha\n\n\nBeta" |
          string:prefix-lines '****' |
          put [(all)] |
          should-be [
            '****Alpha'
            ''
            ''
            '****Beta'
          ]
      }

      >> 'with 3 text lines, intermediate empty lines and final empty lines' {
        put "Alpha\n\n\nBeta\n\n\n\n\nGamma\n\n" |
          string:prefix-lines '****' |
          put [(all)] |
          should-be [
            '****Alpha'
            ''
            ''
            '****Beta'
            ''
            ''
            ''
            ''
            '****Gamma'
            ''
            ''
          ]
      }
    }

    >> 'when indenting empty lines, too' {
      >> 'with empty string' {
        put '' |
          string:prefix-lines &empty-too '# ' |
          should-be '# '
      }

      >> 'with 3 text lines, intermediate empty lines and final empty lines' {
        put "Alpha\n\n\nBeta\n\n\n\n\nGamma\n\n" |
          string:prefix-lines &empty-too '# ' |
          put [(all)] |
          should-be [
            '# Alpha'
            '# '
            '# '
            '# Beta'
            '# '
            '# '
            '# '
            '# '
            '# Gamma'
            '# '
            '# '
          ]
      }
    }
  }

  >> 'unstyling a string' {
    >> 'with non-styled string' {
      var source = 'This is just a basic string'

      string:unstyled $source |
        should-be $source
    }

    >> 'with styled string' {
      echo (styled 'Hello' bold italic green), (styled 'this' italic) is just a (styled 'basic test' bold red) |
        string:unstyled (all) |
        should-be 'Hello, this is just a basic test'
    }
  }

  >> 'pretty string from value' {
    >> 'applied to single-line string' {
      var source = 'Hello, world!'

      string:pretty $source |
        should-be $source
    }

    >> 'applied to multi-line string' {
      var source = "Hello!\n   world!"

      string:pretty $source |
        should-be $source
    }

    >> 'applied to number' {
      string:pretty (num 90) |
        should-be '(num 90)'
    }

    >> 'applied to list' {
      string:pretty [A B C] |
        should-be "[\n A\n B\n C\n]"
    }

    >> 'applied to exception' {
      var exception = ?(fail DODO)

      string:pretty $exception |
        string:unstyled (all) |
        str:has-prefix (all) "Exception: DODO\n" |
        should-be $true
    }
  }
}
