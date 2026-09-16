use path
use ../elvish/cd-hooks elvish-hooks
use ./cd-hooks
use ./paths
use ./test-shared
use ./wrapper

fn get-sdkman-runs { |pre-register|
  var spy = (command:spy)

  tmp wrapper:sdk~ = $spy[command]

  elvish-hooks:test [
    &pre-register=$pre-register

    &before=$cd-hooks:-before-cd~

    &after=$cd-hooks:-after-cd~
  ]

  $spy[get-runs]
}

>> 'SDKMAN' {
  >> 'hooks' {
    >> 'registration' {
      tmp cd-hooks:-before-cd~ = { |_| }
      tmp cd-hooks:-after-cd~ = { }

      tmp paths = [X]
      tmp E:JAVA_HOME = dodo

      test-shared:within-temp-sdkman-home {
        test-shared:install java 23-open &bin

        cd-hooks:register

        >> 'should update PATH' {
          all $paths |
            should-emit &any-order [
              (test-shared:get-current-link java &bin)
              X
            ]
        }

        >> 'should update *_HOME vars' {
          get-env JAVA_HOME |
            should-be (test-shared:get-current-link java)
        }
      }
    }

    >> 'execution' {
      >> 'when source dir has no sdk file and target dir has no sdk file' {
        get-sdkman-runs { |_ _| } |
          should-emit [
            []
          ]
      }

      >> 'when source dir has its sdk file and target dir has no sdk file' {
        get-sdkman-runs { |source-dir _|
          {
            echo java=8.0.502.fx-zulu
            echo gradle=2.10
          } > (path:join $source-dir $paths:sdk-file)
        } |
          should-be [
            [env clear]
          ]
      }

      >> 'when source dir has no sdk file and target dir has its sdk file' {
        get-sdkman-runs { |_ target-dir|
          {
            echo java=23-open
            echo maven=3.9.9
          } > (path:join $target-dir $paths:sdk-file)
        } |
          should-be [
            [env install]
          ]
      }

      >> 'when source dir has its sdk file and target dir has another sdk file' {
        get-sdkman-runs { |source-dir target-dir|
          {
            echo java=8.0.502.fx-zulu
            echo gradle=2.10
          } > (path:join $source-dir $paths:sdk-file)

          {
            echo java=23-open
            echo maven=3.9.9
          } > (path:join $target-dir $paths:sdk-file)
        } |
          should-be [
            [env install]
          ]
      }
    }
  }
}