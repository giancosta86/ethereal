use os
use path
use ./hooks
use ./paths
use ./test-shared
use ./wrapper

fn get-sdkman-runs { |block|
  var spy = (command:spy)

  tmp wrapper:sdk~ = $spy[command]

  $block

  $spy[get-runs]
}

>> 'SDKMAN' {
  >> 'hooks' {
    >> 'when source dir has no sdk file and dest dir has no sdk file' {
      get-sdkman-runs {
        fs:with-temp-dir { |source-dir|
          cd $source-dir

          fs:with-temp-dir { |dest-dir|
            hooks:-before-chdir-hook $dest-dir

            cd $dest-dir

            hooks:-after-chdir-hook $dest-dir
          }
        }
      } |
        should-be []
    }

    >> 'when source dir has its sdk file and dest dir has no sdk file' {
      get-sdkman-runs {
        fs:with-temp-dir { |source-dir|
          cd $source-dir

          {
            echo java=8.0.502.fx-zulu
            echo gradle=2.10
          } > $paths:sdk-file

          fs:with-temp-dir { |dest-dir|
            hooks:-before-chdir-hook $dest-dir

            cd $dest-dir

            hooks:-after-chdir-hook $dest-dir
          }
        }
      } |
        should-be [
          [env clear]
        ]
    }

    >> 'when source dir has no sdk file and dest dir has its sdk file' {
      get-sdkman-runs {
        fs:with-temp-dir { |source-dir|
          cd $source-dir

          fs:with-temp-dir { |dest-dir|
            {
              echo java=23-open
              echo maven=3.9.9
            } > (path:join $dest-dir $paths:sdk-file)

            hooks:-before-chdir-hook $dest-dir

            cd $dest-dir

            hooks:-after-chdir-hook $dest-dir
          }
        }
      } |
        should-be [
          [env install]
        ]
    }

    >> 'when source dir has its sdk file and dest dir has another sdk file' {
      get-sdkman-runs {
        fs:with-temp-dir { |source-dir|
          cd $source-dir

          {
            echo java=8.0.502.fx-zulu
            echo gradle=2.10
          } > $paths:sdk-file

          fs:with-temp-dir { |dest-dir|
            {
              echo java=23-open
              echo maven=3.9.9
            } > (path:join $dest-dir $paths:sdk-file)

            hooks:-before-chdir-hook $dest-dir

            cd $dest-dir

            hooks:-after-chdir-hook $dest-dir
          }
        }
      } |
        should-be [
          [env install]
        ]
    }

    >> 'setting up the environment' {
      >> 'should update PATH' {
        tmp paths = []

        tmp wrapper:sdk~ = { |@arguments|
          set paths = [DODO]
        }

        hooks:setup-env

        put $paths |
          should-be [DODO]
      }

      >> 'should update *_HOME vars' {
        tmp E:JAVA_HOME = ''

        tmp paths = []

        test-shared:with-temp-candidate java { |candidate-root|
          var installed-version-path = (path:join $candidate-root 23-open)

          var current-link-path = (path:join $candidate-root current)

          os:symlink $installed-version-path $current-link-path

          tmp wrapper:sdk~ = { |@arguments|
            set paths = [
              (path:join $current-link-path bin)
            ]
          }

          fs:within-temp-dir {
            hooks:setup-env
          }

          get-env JAVA_HOME |
            should-be $current-link-path
        }
      }
    }
  }
}