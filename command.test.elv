use ./command
use ./fs

var test-block-ok = {
  echo STDOUT
  put [90 92 95 98]
  echo STDERR >&2
}

var test-block-crashing = {
  $test-block-ok

  fail DODO
}

fn should-emit-in-any-order { |expected-items|
  var sorted-actual-items = [(
    all |
    order &key=$to-string~
  )]

  var sorted-expected-items = [(
    all $expected-items |
    order &key=$to-string~
  )]

  put $sorted-actual-items |
    should-be $sorted-expected-items
}


>> 'In command module' {
  >> 'capturing a block' {
    var scenarios = [
      [
        &stream=both
        &type=both
        &expected-data=[
          STDOUT
          [90 92 95 98]
          STDERR
        ]
      ]
      [
        &stream=both
        &type=bytes
        &expected-data=[
          STDOUT
          STDERR
        ]
      ]
      [
        &stream=both
        &type=values
        &expected-data=[
          [90 92 95 98]
        ]
      ]
      [
        &stream=both
        &type=none
        &expected-data=[]
      ]

      [
        &stream=out
        &type=both
        &expected-data=[
          STDOUT
          [90 92 95 98]
        ]
      ]
      [
        &stream=out
        &type=bytes
        &expected-data=[
          STDOUT
        ]
      ]
      [
        &stream=out
        &type=values
        &expected-data=[
          [90 92 95 98]
        ]
      ]
      [
        &stream=out
        &type=none
        &expected-data=[]
      ]

      [
        &stream=err
        &type=both
        &expected-data=[
          STDERR
        ]
      ]
      [
        &stream=err
        &type=bytes
        &expected-data=[
          STDERR
        ]
      ]
      [
        &stream=err
        &type=values
        &expected-data=[]
      ]
      [
        &stream=err
        &type=none
        &expected-data=[]
      ]

      [
        &stream=none
        &type=both
        &expected-data=[]
      ]
      [
        &stream=none
        &type=bytes
        &expected-data=[]
      ]
      [
        &stream=none
        &type=values
        &expected-data=[]
      ]
      [
        &stream=none
        &type=none
        &expected-data=[]
      ]
    ]

    all $scenarios | each { |scenario|
      var stream = $scenario[stream]
      var type = $scenario[type]

      >> 'when &stream='$stream' and &type='$type {
        >> 'when there are no exceptions' {
          var capture-result = (
            command:capture &stream=$stream &type=$type $test-block-ok
          )

          all $capture-result[data] |
            should-emit-in-any-order $scenario[expected-data]

          put $capture-result[exception] |
            should-be $nil
        }

        >> 'when an exception is thrown' {
          var capture-result = (
            command:capture &stream=$stream &type=$type $test-block-crashing
          )

          all $capture-result[data] |
            should-emit-in-any-order $scenario[expected-data]

          put $capture-result[exception] |
            get-fail-content |
            should-be DODO
        }
      }
    }
  }

  >> 'silencing a block' {
    >> 'when no exceptions are thrown' {
      command:capture {
        command:silence $test-block-ok
      } |
        should-be [
          &data=[]
          &exception=$nil
        ]
    }

    >> 'when an exception is thrown' {
      >> 'when &on-exception=both' {
        var capture-result = (
          command:capture {
            command:silence &on-exception=both $test-block-crashing
          }
        )

        all $capture-result[data] |
          should-emit-in-any-order [
            STDOUT
            '[90 92 95 98]'
            STDERR
          ]

        put $capture-result[exception] |
          get-fail-content |
          should-be DODO
      }

      >> 'when &on-exception=data' {
        var capture-result = (
          command:capture {
            command:silence &on-exception=data $test-block-crashing
          }
        )

        all $capture-result[data] |
          should-emit-in-any-order [
            STDOUT
            '[90 92 95 98]'
            STDERR
          ]

        put $capture-result[exception] |
          should-be $nil
      }

      >> 'when &on-exception=exception' {
        var capture-result = (
          command:capture {
            command:silence &on-exception=exception $test-block-crashing
          }
        )

        put $capture-result[data] |
          should-be []

        put $capture-result[exception] |
          get-fail-content |
          should-be DODO
      }

      >> 'when &on-exception=none' {
        var capture-result = (
          command:capture {
            command:silence &on-exception=none $test-block-crashing
          }
        )

        put $capture-result[data] |
          should-be []

        put $capture-result[exception] |
          should-be $nil
      }
    }
  }

  >> 'testing whether a command exists in Bash' {
    >> 'if the command is a program in the path' {
      command:exists-in-bash cat |
        should-be $true
    }

    >> 'if the command is an alias' {
      var test-alias = myTestAlias

      fs:with-path-sandbox ~/.bashrc {
        echo 'alias '$test-alias'=''ls -l''' >> ~/.bashrc

        command:exists-in-bash $test-alias |
          should-be $true
      }
    }

    >> 'if the command does not exist' {
      command:exists-in-bash INEXISTENT |
        should-be $false
    }
  }

  >> 'creating a spy' {
    >> 'when not passing a block' {
      >> 'upon creation' {
        var spy = (command:spy)

        $spy[get-runs] |
          should-be []
      }

      >> 'after one invocation' {
        var spy = (command:spy)

        $spy[command] A B C

        $spy[get-runs] |
          should-be [
            [A B C]
          ]
      }

      >> 'after two invocations' {
        var spy = (command:spy)

        $spy[command] A B C
        $spy[command]

        $spy[get-runs] |
          should-be [
            [A B C]
            []
          ]
      }

      >> 'after three invocations' {
        var spy = (command:spy)

        $spy[command] A B C
        $spy[command]
        $spy[command] X Y

        $spy[get-runs] |
          should-be [
            [A B C]
            []
            [X Y]
          ]
      }
    }

    >> 'when passing a block' {
      var spy = (
        command:spy { |@arguments| count $arguments }
      )

      var output = ($spy[command] X Y Z)

      >> 'the arguments should still be tracked' {
        $spy[get-runs] |
          should-be [
            [X Y Z]
          ]
      }

      >> 'the block should be executed' {
        put $output |
          should-be 3
      }
    }
  }
}