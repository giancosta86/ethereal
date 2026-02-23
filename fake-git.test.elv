use os
use path
use ./fake-git
use ./fs

var valid-fake-git~ = (
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
    >> 'should fail' {
      fails {
        valid-fake-git DODO
      } |
        should-be 'Unsupported "DODO" command'
    }
  }

  >> 'cloning' {
    >> 'when the source map does not include the given source url' {
      >> 'should fail' {
        var fake-git~ = (fake-git:create-command [&])

        fails {
          fake-git clone '<some url>' (os:temp-dir)
        } |
          should-be 'Missing source url "<some url>" in source map'
      }
    }

    >> 'when the source has no main branch' {
      >> 'should fail' {
        var fake-git~ = (fake-git:create-command [
          &'<some url>'=[&]
        ])

        fails {
          fake-git clone '<some url>' (os:temp-dir)
        } |
          should-be 'Missing reference "main" in repository at source url "<some url>"'
      }
    }

    >> 'when a source url with a main reference is requested' {
      >> 'should clone its files to the destination directory' {
        fs:with-temp-dir { |dest|
          valid-fake-git clone '<some url>' $dest

          slurp < (path:join $dest alpha.txt) |
            should-be 'This is a sample test'

          slurp < (path:join $dest beta gamma delta.txt) |
            should-be 'This is another test!'
        }
      }
    }

    >> 'when cloning with -C' {
      >> 'should clone to a directory within the context of the temporary pwd' {
        fs:with-temp-dir { |dest|
          var previous-pwd = $pwd

          valid-fake-git -C $dest clone '<some url>' omega

          slurp < (path:join $dest omega alpha.txt) |
            should-be 'This is a sample test'

          slurp < (path:join $dest omega beta gamma delta.txt) |
            should-be 'This is another test!'

          put $pwd |
            should-be $previous-pwd
        }
      }
    }
  }

  >> 'checkout' {
    >> 'when the branch was not declared in the source map' {
      >> 'should fail' {
        fs:with-temp-dir { |dest|
          valid-fake-git clone '<some url>' $dest

          cd $dest

          fails {
            valid-fake-git checkout UNDECLARED
          } |
            should-be 'Missing reference "UNDECLARED" in repository at source url "<some url>"'
        }
      }
    }

    >> 'when the target directory is not a cloned repository' {
      >> 'should fail' {
        fs:with-temp-dir { |dest|
          cd $dest

          fails {
            valid-fake-git checkout secondary
          } |
            should-be (printf 'The directory "%s" was not cloned via this command instance!' $dest)
        }
      }
    }

    >> 'when the branch in the source map is declared' {
      fn test-scenario { |@git-arguments|
        fs:with-temp-dir { |dest|
          valid-fake-git clone '<some url>' $dest

          cd $dest

          valid-fake-git $@git-arguments

          slurp < (path:join $dest alpha.txt) |
            should-be 'This is another copy of alpha'

          path:join $dest beta gamma delta.txt |
            os:is-regular (all) |
            should-be $false

          slurp < (path:join $dest pi.txt) |
            should-be 'This is Pi'

          slurp < (path:join $dest sigma tau.txt) |
            should-be 'This is Tau'
        }
      }

      >> 'the target should contain only the files in that branch' {
        test-scenario checkout secondary
      }

      >> 'should support --detach' {
        test-scenario checkout --detach secondary
      }

      >> 'when performing the checkout with -C' {
        >> 'the checkout should occur within the directory passed to -C' {
          fs:with-temp-dir { |dest|
            var previous-pwd = $pwd

            valid-fake-git clone '<some url>' $dest

            valid-fake-git -C $dest checkout secondary

            slurp < (path:join $dest alpha.txt) |
              should-be 'This is another copy of alpha'

            path:join $dest beta gamma delta.txt |
              os:is-regular (all) |
              should-be $false

            slurp < (path:join $dest pi.txt) |
              should-be 'This is Pi'

            slurp < (path:join $dest sigma tau.txt) |
              should-be 'This is Tau'

            put $pwd |
              should-be $previous-pwd
          }
        }
      }
    }

    >> 'when the branch is empty' {
      >> 'the target should contain no more files' {
        fs:with-temp-dir { |dest|
          valid-fake-git clone '<some url>' $dest

          cd $dest

          valid-fake-git checkout empty

          put *[nomatch-ok] |
            put [(all)] |
            should-be []
        }
      }
    }

    >> 'when cloning branches in sibling directories' {
      >> 'both directories should coexist' {
        fs:with-temp-dir { |temp-dir|
          var main-dir = (path:join $temp-dir A)
          valid-fake-git clone '<some url>' $main-dir

          var secondary-dir = (path:join $temp-dir B)
          valid-fake-git clone '<some url>' $secondary-dir
          valid-fake-git -C $secondary-dir checkout secondary

          path:join $main-dir beta gamma delta.txt |
            os:is-regular (all) |
            should-be $true

          path:join $secondary-dir sigma tau.txt |
            os:is-regular (all) |
            should-be $true
        }
      }
    }
  }

  >> 'getting the current reference' {
    >> 'after cloning' {
      fs:with-temp-dir { |temp-dir|
        valid-fake-git clone '<some url>' $temp-dir

        cd $temp-dir

        valid-fake-git rev-parse --abbrev-ref HEAD |
          should-be main
      }
    }

    >> 'after checkout' {
      fs:with-temp-dir { |temp-dir|
        valid-fake-git clone '<some url>' $temp-dir

        cd $temp-dir

        valid-fake-git checkout secondary

        valid-fake-git rev-parse --abbrev-ref HEAD |
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

    >> 'should update the files' {
      fs:with-temp-dir { |temp-dir|
        var transient-fake-git~ = (fake-git:create-command { put $current-map })

        transient-fake-git clone '<some url>' $temp-dir

        cd $temp-dir

        {
          slurp < alpha.txt |
            should-be $initial-map['<some url>'][main][alpha.txt]

          os:is-regular beta.txt |
            should-be $false
        }

        transient-fake-git checkout secondary

        {
          os:is-regular alpha.txt |
            should-be $false

          slurp < beta.txt |
            should-be $initial-map['<some url>'][secondary][beta.txt]
        }

        set current-map = $updated-map

        transient-fake-git checkout main

        transient-fake-git checkout secondary

        {
          os:is-regular alpha.txt |
            should-be $false

          slurp < beta.txt |
            should-be $initial-map['<some url>'][secondary][beta.txt]
        }

        transient-fake-git pull

        slurp < beta.txt |
            should-be $updated-map['<some url>'][secondary][beta.txt]
      }
    }
  }
}