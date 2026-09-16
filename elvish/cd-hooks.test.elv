use ./cd-hooks

>> 'Elvish' {
  >> 'chdir hooks' {
    >> 'temporary reset' {
      tmp before-chdir = [A B C]
      tmp after-chdir = [X Y Z]

      cd-hooks:with-reset {
        put $before-chdir |
          should-be-empty

        put $after-chdir |
          should-be-empty
      }

      put $before-chdir |
        should-be [A B C]

      put $after-chdir |
        should-be [X Y Z]
    }

    >> 'registration' {
      >> 'should always provide both hooks' {
        >> 'with no handler' {
          cd-hooks:test [&]
        }

        >> 'with just before handler' {
          var called = $false

          cd-hooks:test [
            &before={ |_|
              set called = $true
            }
          ]

          put $called |
            should-be $true
        }

        >> 'with just after handler' {
          var called = $false

          cd-hooks:test [
            &after={
              set called = $true
            }
          ]

          put $called |
            should-be $true
        }

        >> 'with both handlers' {
          var before-called = $false
          var after-called = $false

          cd-hooks:test [
            &before={ |_|
              set before-called = $true
            }
            &after={
              set after-called = $true
            }
          ]

          put $before-called |
            should-be $true

          put $after-called |
            should-be $true
        }
      }

      >> 'after-chdir automatic execution' {
        >> 'by default' {
          var called = $false

          cd-hooks:with-reset {
            cd-hooks:register [
              &before={ |_|
                fail 'This should not run!'
              }
              &after={
                set called = $true
              }
            ]
          }

          put $called |
            should-be $true
        }

        >> 'when disabled' {
          cd-hooks:with-reset {
            cd-hooks:register [
              &before={ |_|
                fail 'This should not run!'
              }
              &after={
                fail 'This should not run!'
              }
              &after-now=$false
            ]
          }
        }
      }
    }

    >> 'testing' {
      >> 'when passing empty params' {
        cd-hooks:test [&] |
          should-emit []
      }

      >> 'by default' {
        var before-called = $false

        var after-called = $false

        cd-hooks:test [
          &before={ |_|
            set before-called = $true
          }
          &after={
            set after-called = $true
          }
        ]

        put $before-called |
          should-be $true

        put $after-called |
          should-be $true
      }

      >> 'when passing pre-register' {
        var source-dir = $nil
        var target-dir = $nil

        var before-hook-test = $nil
        var after-hook-test = $nil

        cd-hooks:test [
          &pre-register={ |test-source-dir test-target-dir|
            set source-dir = $test-source-dir

            set target-dir = $test-target-dir
          }
          &before={ |target-dir-in-hook|
            var pwd-in-before = $pwd

            set before-hook-test = {
              put $pwd-in-before |
                should-be $source-dir

              put $target-dir-in-hook |
                should-be $target-dir
            }
          }
          &after={
            var pwd-in-after = $pwd

            set after-hook-test = {
              put $pwd-in-after |
                should-be $target-dir
            }
          }
        ]

        $before-hook-test

        $after-hook-test
      }

      >> 'when passing pre-unregister' {
        var source-dir = $nil
        var target-dir = $nil

        cd-hooks:test [
          &before={ |target|
            set source-dir = $pwd
            set target-dir = $target
          }
          &pre-unregister={ |source target|
            put $source |
              should-be $source-dir

            put $target |
              should-be $target-dir
          }
        ]
      }

      >> 'when passing both pre-register and pre-unregister' {
        var source-dir = $nil
        var target-dir = $nil

        cd-hooks:test [
          &pre-register={ |source target|
            set source-dir = $source
            set target-dir = $target
          }
          &pre-unregister={ |source target|
            put $source |
              should-be $source-dir

            put $target |
              should-be $target-dir
          }
        ]
      }

      >> 'should emit the output of pre-register and pre-unregister' {
        cd-hooks:test [
          &pre-register={ |_ _|
            put 90
            echo Hello
          }
          &pre-unregister={ |_ _|
            put 92
            echo Alpha
          }
        ] |
          should-emit &any-order [
            90
            Hello
            92
            Alpha
          ]
      }
    }

    >> 'properties' {
      >> 'non-reentrance' {
        var before-calls = 0

        var after-calls = 0

        cd-hooks:test [
          &before={ |_|
            set before-calls = (+ $before-calls 1)

            fs:with-temp-dir { |another-temp-dir|
              cd $another-temp-dir
            }
          }
          &after={
            set after-calls = (+ $after-calls 1)

            fs:with-temp-dir { |yet-another-temp-dir|
              cd $yet-another-temp-dir
            }
          }
        ]

        put $before-calls |
          should-be 1

        put $after-calls |
          should-be 1
      }

      >> 'non-repetition on current directory' {
        var before-calls = 0

        var after-calls = 0

        cd-hooks:test [
          &before={ |_|
            set before-calls = (+ $before-calls 1)
          }
          &after={
            set after-calls = (+ $after-calls 1)
          }
          &pre-unregister={ |_ target-dir|
            cd $target-dir
          }
        ]

        put $before-calls |
          should-be 1

        put $after-calls |
          should-be 1
      }

      >> 'skipping missing directories' {
        var before-called = $false
        var after-called = $false

        cd-hooks:with-reset {
          fs:within-temp-dir {
            cd-hooks:register [
              &before={ |target-dir|
                set before-called = $true
              }
              &after={
                set after-called = $true
              }
              &after-now=$false
            ]

            try {
              cd SOME-MISSING-DIR
            } catch {
              # Just do nothing
            } finally {
              set before-chdir = []
              set after-chdir = []
            }
          }
        }

        put $before-called |
          should-be $false

        put $after-called |
          should-be $false
      }
    }
  }
}
