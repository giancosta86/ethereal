use ../command
use ./from-env-var

>> 'Tracer based on an environment variable' {
  var test-var = MY_TRACER_TEST

  var tracer = (from-env-var:create $test-var)

  var tracer-test-block = {
    $tracer[section] &emoji=🐿 'Description' 'Test content'
  }

  >> 'when the variable is enabled' {
    >> 'should write to console' {
      set-env $test-var 1

      command:capture $tracer-test-block |
        put (all)[output] |
        should-be "🐿 Description:\nTest content\n🐿🐿🐿\n"
    }
  }

  >> 'when the variable is disabled' {
    >> 'should remain silent' {
      set-env $test-var '<SOME UNRECOGNIZED VALUE>'

      command:capture $tracer-test-block |
        put (all)[output] |
        should-be ''
    }
  }

  >> 'when the variable is missing' {
    >> 'should remain silent' {
      unset-env $test-var

      command:capture $tracer-test-block |
        put (all)[output] |
        should-be ''
    }
  }
}
