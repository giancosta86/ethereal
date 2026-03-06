use ./on-off

>> 'Tracer with manual on/off controls' {
  var tracer = (on-off:create)

  var tracer-test-block = {
    $tracer[section] &emoji=🐬 Description 'Test content' 2>&1
  }

  >> 'upon creation' {
    >> 'should be disabled by default' {
      $tracer-test-block |
        should-emit []
    }
  }

  >> 'when enabled' {
    >> 'should write to console' {
      $tracer[enable]

      $tracer-test-block |
        should-emit [
          '🐬 Description:'
          'Test content'
          🐬🐬🐬
        ]
    }
  }

  >> 'when disabled' {
    >> 'should remain silent' {
      $tracer[enable]
      $tracer[disable]

      $tracer-test-block |
        should-emit []
    }
  }

  >> 'when enabling via set-enabled' {
    $tracer[set-enabled] $true

    var test-message = '🐞 Hello, world!'

    $tracer[echo] $test-message |
      should-emit [
        $test-message
      ]
  }
}
