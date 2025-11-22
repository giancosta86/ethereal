use os
use str
use ./command
use ./curl
use ./fs

var test-website = https://jsonplaceholder.typicode.com/todos/1

var curl = (external curl)

fn with-factory-reset-curl { |block|
  fs:with-file-sandbox $curl:-configuration-path {
    os:remove-all $curl:-configuration-path

    $block
  }
}

>> 'In curl module' {
  >> 'when not altering the output settings' {
    with-factory-reset-curl {
      command:capture &stream=err {
        curl $test-website
      } |
        put (all)[data] |
        str:join "\n" (all) |
        str:contains (all) '%' |
          should-be $true
    }
  }

  >> 'when displaying errors only' {
    with-factory-reset-curl {
      curl:display-errors-only

      command:capture &stream=err {
        curl $test-website
      } |
        put (all)[data] |
        str:join "\n" (all) |
        str:contains (all) '%' |
          should-be $false
    }
  }
}