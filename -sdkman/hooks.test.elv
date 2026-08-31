use path
use ./hooks
use ./paths
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
  }
}