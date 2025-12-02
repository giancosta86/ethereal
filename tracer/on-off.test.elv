use ./on-off

>> 'Tracer with manual on/off controls' {
  var tracer = (on-off:create)

  var tracer-test-block = {
    $tracer[section] &emoji=🐬 Description 'Test content'
  }

  >> 'upon creation' {
    >> 'should be disabled by default' {
      $tracer-test-block |
        put [(all)] |
        should-be []
    }
  }

  >> 'when enabled' {
    >> 'should write to console' {
      $tracer[enable]

      $tracer-test-block |
        put [(all)] |
        should-be [
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
        put [(all)] |
        should-be []
    }
  }

  >> 'when enabling via set-enabled' {
    $tracer[set-enabled] $true

    var test-message = '🐞 Hello, world!'

    $tracer[echo] $test-message |
      put [(all)] |
      should-be [
        $test-message
      ]
  }
}
