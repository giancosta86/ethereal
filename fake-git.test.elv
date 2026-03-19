use os
use path
use ./fake-git
use ./fs

var test-git~ = (
  fake-git:create-command [
    &'<some url>'=[
      &main=[
        &alpha.txt='This is a sample test'
        &beta/gamma/delta.txt='This is another test!'
      ]

      &secondary=[
        &alpha.txt='This is another copy of alpha'
        &pi.txt='This is Pi'
        &sigma/tau.txt='This is Tau'
      ]

      &empty=[&]
    ]
  ]
)

>> 'In fake-git module' {
  >> 'passing an unknown command' {
    fails {
      test-git DODO
    } |
      should-be 'Unsupported "DODO" command'
  }

  >> 'cloning' {
    >> 'when the source map does not include the given source url' {
      var crashing-git~ = (fake-git:create-command [&])

      fails {
        crashing-git clone '<some url>' (os:temp-dir)
      } |
        should-be 'Missing source url "<some url>" in source map'
    }

    >> 'when the source has no main branch' {
      var crashing-git~ = (fake-git:create-command [
        &'<some url>'=[&]
      ])

      fails {
        crashing-git clone '<some url>' (os:temp-dir)
      } |
        should-be 'Missing reference "main" in repository at source url "<some url>"'
    }

    >> 'when a source url with a main reference is requested' {
      fs:with-temp-dir { |temp-dir|
        test-git clone '<some url>' $temp-dir

        slurp < (path:join $temp-dir alpha.txt) |
          should-be 'This is a sample test'

        slurp < (path:join $temp-dir beta gamma delta.txt) |
          should-be 'This is another test!'
      }
    }

    >> 'when cloning with -C' {
      fs:with-temp-dir { |temp-dir|
        var previous-pwd = $pwd

        test-git -C $temp-dir clone '<some url>' omega

        slurp < (path:join $temp-dir omega alpha.txt) |
          should-be 'This is a sample test'

        slurp < (path:join $temp-dir omega beta gamma delta.txt) |
          should-be 'This is another test!'

        put $pwd |
          should-be $previous-pwd
      }
    }
  }

  >> 'checkout' {
    >> 'when the target directory is not a cloned repository' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        fails {
          test-git checkout secondary
        } |
          should-be (printf 'The directory "%s" was not cloned via this command instance!' $temp-dir)
      }
    }

    >> 'when the branch was not declared in the source map' {
      fs:with-temp-dir { |temp-dir|
        test-git clone '<some url>' $temp-dir

        cd $temp-dir

        fails {
          test-git checkout UNDECLARED
        } |
          should-be 'Missing reference "UNDECLARED" in repository at source url "<some url>"'
      }
    }

    >> 'when the branch in the source map is declared' {
      fn common-scenario { |@git-arguments|
        fs:with-temp-dir { |temp-dir|
          test-git clone '<some url>' $temp-dir

          cd $temp-dir

          test-git $@git-arguments

          slurp < (path:join $temp-dir alpha.txt) |
            should-be 'This is another copy of alpha'

          path:join $temp-dir beta gamma delta.txt |
            should-not-be-regular

          slurp < (path:join $temp-dir pi.txt) |
            should-be 'This is Pi'

          slurp < (path:join $temp-dir sigma tau.txt) |
            should-be 'This is Tau'
        }
      }

      >> 'the target should contain only the files in that branch' {
        common-scenario checkout secondary
      }

      >> 'should support --detach' {
        common-scenario checkout --detach secondary
      }

      >> 'when performing the checkout with -C' {
        >> 'the checkout should occur within the directory passed to -C' {
          fs:with-temp-dir { |temp-dir|
            var previous-pwd = $pwd

            test-git clone '<some url>' $temp-dir

            test-git -C $temp-dir checkout secondary

            slurp < (path:join $temp-dir alpha.txt) |
              should-be 'This is another copy of alpha'

            path:join $temp-dir beta gamma delta.txt |
              should-not-be-regular

            slurp < (path:join $temp-dir pi.txt) |
              should-be 'This is Pi'

            slurp < (path:join $temp-dir sigma tau.txt) |
              should-be 'This is Tau'

            put $pwd |
              should-be $previous-pwd
          }
        }
      }
    }

    >> 'when the branch is empty' {
      fs:with-temp-dir { |temp-dir|
        test-git clone '<some url>' $temp-dir

        cd $temp-dir

        test-git checkout empty

        put *[nomatch-ok] |
          should-emit []
      }
    }

    >> 'when cloning branches in sibling directories' {
      >> 'both directories should coexist' {
        fs:with-temp-dir { |temp-dir|
          var main-dir = (path:join $temp-dir A)
          test-git clone '<some url>' $main-dir

          var secondary-dir = (path:join $temp-dir B)
          test-git clone '<some url>' $secondary-dir
          test-git -C $secondary-dir checkout secondary

          path:join $main-dir beta gamma delta.txt |
            should-be-regular

          path:join $secondary-dir sigma tau.txt |
            should-be-regular
        }
      }
    }
  }

  >> 'getting the current reference' {
    >> 'after cloning' {
      fs:with-temp-dir { |temp-dir|
        test-git clone '<some url>' $temp-dir

        cd $temp-dir

        test-git rev-parse --abbrev-ref HEAD |
          should-be main
      }
    }

    >> 'after checkout' {
      fs:with-temp-dir { |temp-dir|
        test-git clone '<some url>' $temp-dir

        cd $temp-dir

        test-git checkout secondary

        test-git rev-parse --abbrev-ref HEAD |
          should-be secondary
      }
    }
  }

  >> 'pulling' {
    var initial-map = [
      &'<some url>'=[
        &main=[
          &alpha.txt='ALPHA - FIRST VERSION'
        ]
        &secondary=[
          &beta.txt='BETA - FIRST VERSION'
        ]
      ]
    ]

    var updated-map = [
      &'<some url>'=[
        &secondary=[
          &beta.txt='BETA - UPDATED VERSION'
        ]
      ]
    ]

    var current-map = $initial-map

    fn should-be-on-initial-main-branch {
      slurp < alpha.txt |
        should-be $initial-map['<some url>'][main][alpha.txt]

      put beta.txt |
        should-not-be-regular
    }

    fn should-be-on-initial-secondary-branch {
      put alpha.txt |
        should-not-be-regular

      slurp < beta.txt |
        should-be $initial-map['<some url>'][secondary][beta.txt]
    }

    fn should-be-on-updated-secondary-branch {
      put alpha.txt |
        should-not-be-regular

      slurp < beta.txt |
        should-be $updated-map['<some url>'][secondary][beta.txt]
    }

    >> 'should update the files' {
      fs:with-temp-dir { |temp-dir|
        var lambda-provider = { put $current-map }

        var transient-git~ = (fake-git:create-command $lambda-provider)

        {
          transient-git clone '<some url>' $temp-dir

          cd $temp-dir

          should-be-on-initial-main-branch
        }

        {
          transient-git checkout secondary

          should-be-on-initial-secondary-branch
        }

        set current-map = $updated-map

        {
          transient-git checkout main

          should-be-on-initial-main-branch
        }

        {
          transient-git checkout secondary

          should-be-on-initial-secondary-branch
        }

        {
          transient-git pull

          should-be-on-updated-secondary-branch
        }
      }
    }
  }

  >> 'getting the source url' {
    fs:with-temp-dir { |temp-dir|
      test-git clone '<some url>' $temp-dir

      cd $temp-dir

      test-git remote get-url origin |
        should-be '<some url>'
    }
  }
}