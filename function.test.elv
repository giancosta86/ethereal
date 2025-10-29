use str
use ./function

>> 'In function module' {
  >> 'getting single input' {
    >> 'when it is passed as argument' {
      function:get-single-input Alpha |
        should-be Alpha
    }

    >> 'when it is passed via pipe' {
      put Alpha |
        function:get-single-input |
        should-be Alpha
    }

    >> 'when multiple args are passed' {
      >> 'should fail' {
        throws {
          function:get-single-input Alpha Beta
        } |
          str:contains (all)[reason][content] 'Arity mismatch!'
      }
    }

    >> 'when multiple values are passed via pipe' {
      >> 'should fail' {
        throws {
          put Alpha Beta |
            function:get-single-input
        } |
          to-string (all) |
          str:contains (all) 'arity mismatch' |
          should-be $true
      }
    }
  }

  >> 'getting input flow' {
    >> 'when multiple arguments are passed' {
      function:get-input-flow Alpha Beta |
        put [(all)] |
        should-be [Alpha Beta]
    }

    >> 'when multiple values are passed via pipe' {
      put Gamma Delta |
        function:get-input-flow |
        put [(all)] |
        should-be [Gamma Delta]
    }

    >> 'when both arguments and pipe values are passed' {
      >> 'pipe values are followed by arguments' {
        put Alpha Beta |
          function:get-input-flow Ro Sigma |
          put [(all)] |
          should-be [Alpha Beta Ro Sigma]
      }
    }
  }
}