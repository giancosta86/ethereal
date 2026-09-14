use ./chdir-hooks

>> 'Elvish' {
  >> 'chdir hooks' {
    >> 'temporary reset' {
      tmp before-chdir = [A B C]
      tmp after-chdir = [X Y Z]

      chdir-hooks:with-temp-reset {
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

    >> 'pair creation' {
      >> 'should always provide both hooks' {
        >> 'with no handler' {
          chdir-hooks:test [&] { |_ _| }
        }

        >> 'with just before handler' {
          var called = $false

          put [
            &before={ |_|
              set called = $true
            }
          ] |
            chdir-hooks:test { |_ _| }

          put $called |
            should-be $true
        }

        >> 'with just after handler' {
          var called = $false

          put [
            &after={
              set called = $true
            }
          ] |
            chdir-hooks:test { |_ _| }

          put $called |
            should-be $true
        }

        >> 'with both handlers' {
          var before-called = $false
          var after-called = $false

          put [
            &before={ |_|
              set before-called = $true
            }
            &after={
              set after-called = $true
            }
          ] |
            chdir-hooks:test { |_ _| }

          put $before-called |
            should-be $true

          put $after-called |
            should-be $true
        }
      }
    }

    >> 'registration' {
        >> 'after-chdir automatic execution' {
          >> 'by default' {
            var called = $false

            chdir-hooks:with-temp-reset {
              chdir-hooks:register [
                &before={ |_|
                  fail 'This should not run!'
                }
                &after={
                  set called = $true
                }
              ]

              put $called |
                should-be $true
            }
          }

          >> 'when disabled' {
            chdir-hooks:with-temp-reset {
              chdir-hooks:register [
                &before={ |_|
                  fail 'This should not run!'
                }
                &after={
                  fail 'This should not run!'
                }
                &run-after=$false
              ]
            }
          }
        }
      }
  }
}
