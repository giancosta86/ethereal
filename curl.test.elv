use os
use ./curl
use ./fs

var test-website = https://jsonplaceholder.typicode.com/todos/1

var curl = (external curl)

fn with-factory-reset-curl { |block|
  fs:with-path-sandbox $curl:configuration-path {
    os:remove-all $curl:configuration-path

    $block
  }
}

>> 'In curl module' {
  fn expect-progress { |progress-visible|
    var assertion = (
      if $progress-visible {
        put $should-contain~
      } else {
        put $should-not-contain~
      }
    )

    capture {
        curl $test-website
      } |
        $assertion %
  }

  >> 'when not altering the output settings' {
    with-factory-reset-curl {
      expect-progress $true
    }
  }

  >> 'when displaying errors only' {
    with-factory-reset-curl {
      curl:display-errors-only

      expect-progress $false
    }
  }

  >> 'when using a block handler to display errors only' {
    curl:with-silence {
      expect-progress $false
    }
  }
}