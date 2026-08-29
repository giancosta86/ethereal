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
  >> 'when not altering the output settings' {
    with-factory-reset-curl {
      capture &stream=err {
        curl $test-website
      } |
        should-contain %
    }
  }

  >> 'when displaying errors only' {
    with-factory-reset-curl {
      curl:display-errors-only

      capture {
        curl $test-website
      } |
        should-not-contain %
    }
  }

  >> 'when using a block handler to display errors only' {
    curl:with-silence {
      capture {
        curl $test-website
      } |
        should-not-contain %
    }
  }
}