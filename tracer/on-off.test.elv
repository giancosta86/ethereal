use ../command
use ./on-off

>> 'Manual on-off tracer' {
  var tracer = (on-off:create)

  var tracer-test-block = {
    $tracer[section] &emoji=🐬 'Description' 'Test content'
  }

  >> 'upon creation' {
    >> 'should be disabled' {
      command:capture $tracer-test-block |
        put (all)[output] |
        should-be ''
    }
  }

  >> 'when enabled' {
    >> 'should write to console' {
      $tracer[enable]

      command:capture $tracer-test-block |
        put (all)[output] |
        should-be "🐬 Description:\nTest content\n🐬🐬🐬\n"
    }
  }

  >> 'when disabled' {
    >> 'should remain silent' {
      $tracer[enable]
      $tracer[disable]

      command:capture $tracer-test-block |
        put (all)[output] |
        should-be ''
    }
  }

  >> 'when the enabled is passed via setter' {
    >> 'should work' {
      var tracer = (on-off:create)
      $tracer[set-enabled] $true

      var test-message = '🐞 Hello, world!'

      command:capture {
        $tracer[echo] $test-message
      } |
        put (all)[output] |
        should-be $test-message"\n"
    }
  }
}
