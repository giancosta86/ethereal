use ./exception

>> 'In the exception module' {
  >> 'detecting an exception' {
    >> 'applied to number' {
      exception:is-exception 90 |
        should-be $false
    }

    >> 'applied to divide-by-zero error' {
      exception:is-exception ?(/ 8 0) |
        should-be $true
    }

    >> 'applied to fail' {
      exception:is-exception ?(fail DODO) |
        should-be $true
    }

    >> 'applied to return' {
      exception:is-exception ?(return) |
        should-be $true
    }
  }

  >> 'retrieving exception reason' {
    >> 'applied to number' {
      exception:get-reason 90 |
        should-be $nil
    }

    >> 'applied to divide-by-zero error' {
      exception:get-reason ?(/ 8 0) |
        should-not-be $nil
    }

    >> 'applied to fail' {
      exception:get-reason ?(fail DODO) |
        should-not-be $nil
    }

    >> 'applied to return' {
      exception:get-reason ?(return) |
        should-not-be $nil
    }
  }

  >> 'detecting fail' {
    >> 'applied to number' {
      exception:is-fail 90 |
        should-be $false
    }

    >> 'applied to divide-by-zero error' {
      exception:is-fail ?(/ 8 0) |
        should-be $false
    }

    >> 'applied to fail' {
      exception:is-fail ?(fail DODO) |
        should-be $true
    }

    >> 'applied to fail with $nil content' {
      exception:is-fail ?(fail $nil) |
        should-be $true
    }

    >> 'applied to return' {
      exception:is-fail ?(return) |
        should-be $false
    }
  }

  >> 'retrieving fail content' {
    >> 'applied to number' {
      exception:get-fail-content 90 |
        should-be $nil
    }

    >> 'applied to divide-by-zero error' {
      exception:get-fail-content ?(/ 8 0) |
        should-be $nil
    }

    >> 'applied to fail' {
      exception:get-fail-content ?(fail DODO) |
        should-be DODO
    }

    >> 'applied to return' {
      exception:get-fail-content ?(return) |
        should-be $nil
    }
  }

  >> 'detecting return' {
    >> 'applied to number' {
      exception:is-return 90 |
        should-be $false
    }

    >> 'applied to divide-by-zero error' {
      exception:is-return ?(/ 8 0) |
        should-be $false
    }

    >> 'applied to fail' {
      exception:is-return ?(fail DODO) |
        should-be $false
    }

    >> 'applied to return' {
      exception:is-return ?(return) |
        should-be $true
    }
  }
}
