use ./from-env-var

>> 'Tracer based on an environment variable' {
  var test-var = MY_TRACER_TEST

  var tracer = (from-env-var:create $test-var)

  var tracer-test-block = {
    $tracer[section] &emoji=🐿 Description 'Test content' 2>&1
  }

  >> 'when the variable is enabled' {
    >> 'should write to console' {
      set-env $test-var 1

      $tracer-test-block |
        should-emit [
          '🐿 Description:'
          'Test content'
          🐿🐿🐿
        ]
    }
  }

  >> 'when the variable has an unrecognized value' {
    >> 'should remain silent' {
      set-env $test-var '<SOME UNRECOGNIZED VALUE>'

      $tracer-test-block |
        should-emit []
    }
  }

  >> 'when the variable is missing' {
    >> 'should remain silent' {
      unset-env $test-var

      $tracer-test-block |
        should-emit []
    }
  }
}
