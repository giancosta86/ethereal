use os
use str
use ./command
use ./fs

>> 'In command module' {
  var test-block-ok = {
    echo STDOUT
    sleep 10ms
    echo STDERR >&2
    put 90
  }

  var test-block-crashing = {
    $test-block-ok

    fail DODO
  }

  >> 'testing whether a command exists in Bash' {
    >> 'if the command is a program in the path' {
      >> 'should output $true' {
        command:exists-in-bash cat |
          should-be $true
      }
    }

    >> 'if the command is an alias' {
      >> 'should output $true' {
        var test-alias = myTestAlias

        fs:with-file-sandbox ~/.bashrc {
          echo 'alias '$test-alias'=''ls -l''' >> ~/.bashrc

          command:exists-in-bash $test-alias |
            should-be $true
        }
      }
    }

    >> 'if the command does not exist' {
      >> 'should output $false' {
        command:exists-in-bash INEXISTENT |
          should-be $false
      }
    }
  }

  >> 'capturing a block' {
    >> 'when asking for an invalid stream' {
      throws {
        command:capture &keep-stream=INEXISTENT {}
      } |
        get-fail-content |
        should-be 'Invalid stream setting: INEXISTENT'
    }

    >> 'when the block throws no exceptions' {
      >> 'when asking for both streams' {
        command:capture &keep-stream=both $test-block-ok |
          should-be [
            &output="STDOUT\nSTDERR\n"
            &exception=$nil
          ]
      }

      >> 'when asking for stdout' {
        command:capture &keep-stream=out $test-block-ok |
          should-be [
            &output="STDOUT\n"
            &exception=$nil
          ]
      }

      >> 'when asking for stderr' {
        command:capture &keep-stream=err $test-block-ok |
          should-be [
            &output="STDERR\n"
            &exception=$nil
          ]
      }

      >> 'when asking for no stream' {
        command:capture &keep-stream=none $test-block-ok |
          should-be [
            &output=''
            &exception=$nil
          ]
      }
    }

    >> 'when the block throws an exception' {
      >> 'when asking for both streams' {
        var result = (
          command:capture &keep-stream=both $test-block-crashing
        )

        put $result[output] |
          should-be "STDOUT\nSTDERR\n"

        put $result[exception] |
          should-not-be $nil
      }

      >> 'when asking for stdout' {
        var result = (
          command:capture &keep-stream=out $test-block-crashing
        )

        put $result[output] |
          should-be "STDOUT\n"

        put $result[exception] |
          should-not-be $nil
      }

      >> 'when asking for stderr' {
        var result = (
          command:capture &keep-stream=err $test-block-crashing
        )

        put $result[output] |
          should-be "STDERR\n"

        put $result[exception] |
          should-not-be $nil
      }

      >> 'when asking for no stream' {
        var result = (
          command:capture &keep-stream=none $test-block-crashing
        )

        put $result[output] |
          should-be ''

        put $result[exception] |
          should-not-be $nil
      }
    }
  }

  >> 'silencing a block' {
    >> 'when no exceptions are thrown' {
      command:capture {
        command:silence $test-block-ok
      } |
        should-be [
          &output=''
          &exception=$nil
        ]
    }

    >> 'when an exception is thrown' {
      command:capture {
        command:silence $test-block-crashing
      } |
        should-be [
          &output=''
          &exception=$nil
        ]
    }
  }

  >> 'silencing until exception' {
    >> 'when no exceptions are thrown' {
      command:capture {
        command:silence-until-exception {
          $test-block-ok
        }
      } |
        should-be [
          &output=''
          &exception=$nil
        ]
    }

    >> 'when an exception is thrown' {
      var capture-result = (
        command:capture {
          command:silence-until-exception {
            $test-block-crashing
          }
        }
      )

      put $capture-result[output] |
        should-be "❌ Exception while running block!\nSTDOUT\nSTDERR\n\n❌❌❌\n"

      put $capture-result[exception] |
        get-fail-content |
        should-be DODO
    }
  }
}