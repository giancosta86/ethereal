use os
use path
use str
use ./fs

fn -create-temp-tree { |temp-root|
  var alpha-file = (path:join $temp-root alpha)
  print Alpha > $alpha-file

  var beta-dir = (path:join $temp-root beta)
  var gamma-dir = (path:join $beta-dir gamma)
  os:mkdir-all $gamma-dir

  var delta-file = (path:join $gamma-dir delta)
  print Delta > $delta-file

  put [
    &alpha-file=$alpha-file
    &beta-dir=$beta-dir
    &gamma-dir=$gamma-dir
    &delta-file=$delta-file
  ]
}

>> 'In fs module' {
  >> 'ensuring pwd is not in given directory' {
    var temp-dir = (os:temp-dir)
    defer { os:remove-all $temp-dir }

    var nested-path = (path:join $temp-dir A B C D E)
    os:mkdir-all $nested-path

    cd $nested-path

    put $pwd |
      should-be $nested-path

    fs:ensure-not-in-directory $temp-dir

    put $pwd |
      should-be (path:dir $temp-dir)
  }

  >> 'requesting a temp file path' {
    >> 'when not passing a pattern' {
      >> 'should use the default pattern' {
        var temp-path = (fs:temp-file-path)
        defer { os:remove-all $temp-path }

        path:base $temp-path |
          str:has-prefix (all) 'elvish-' |
          should-be $true
      }
    }

    >> 'when passing a custom pattern' {
      var custom-prefix = 'alpha-'
      var custom-suffix = '-omega'

      var temp-path = (fs:temp-file-path &pattern=$custom-prefix'*'$custom-suffix)
      defer { os:remove-all $temp-path }

      >> 'should have the requested prefix' {
        path:base $temp-path |
          str:has-prefix (all) $custom-prefix |
          should-be $true
      }

      >> 'should have the requested suffix' {
        path:base $temp-path |
          str:has-suffix (all) $custom-suffix |
          should-be $true
      }
    }
  }

  >> 'consuming a temp file path' {
    >> 'should delete the temp path available only within the consumer' {
      var actual-path

      fs:with-temp-file { |temp-path|
        os:is-regular $temp-path |
          should-be $true

        set actual-path = $temp-path
      }

      os:is-regular $actual-path |
        should-be $false
    }

    >> 'should support a custom pattern' {
      var custom-prefix = 'alpha-'
      var custom-suffix = '-omega'

      fs:with-temp-file &pattern=$custom-prefix'*'$custom-suffix { |temp-path|
        var temp-base = (path:base $temp-path)

        str:has-prefix $temp-base $custom-prefix |
          should-be $true

        str:has-suffix $temp-base $custom-suffix |
          should-be $true
      }
    }
  }

  >> 'consuming a temp directory path' {
    >> 'should make the temp path available only within the consumer' {
      var actual-path

      fs:with-temp-dir { |temp-dir|
        os:is-dir $temp-dir |
          should-be $true

        set actual-path = $temp-dir
      }

      os:is-dir $actual-path |
        should-be $false
    }

    >> 'should support a custom pattern' {
      var custom-prefix = 'alpha-'
      var custom-suffix = '-omega'

      fs:with-temp-dir &pattern=$custom-prefix'*'$custom-suffix { |temp-path|
        var temp-base = (path:base $temp-path)

        str:has-prefix $temp-base $custom-prefix |
          should-be $true

        str:has-suffix $temp-base $custom-suffix |
          should-be $true
      }
    }
  }

  >> 'the touch operation' {
    fs:with-temp-dir { |temp-directory|
      var file-path = (path:join $temp-directory DODO)
      fs:touch $file-path

      >> 'should create a file' {
        os:is-regular $file-path |
          should-be $true
      }

      >> 'should create an empty file' {
        put (os:stat $file-path)[size] |
          should-be 0
      }
    }
  }

  >> 'the copy operation' {
    >> 'should copy a file' {
      fs:with-temp-file { |sigma-path|
        fs:with-temp-file { |tau-path|
          print Sigma > $sigma-path

          fs:copy $sigma-path $tau-path

          os:is-regular $sigma-path |
            should-be $true

          slurp < $tau-path |
            should-be Sigma
        }
      }
    }

    >> 'should copy a directory' {
      fs:with-temp-dir { |temp-directory|
        var temp-tree = (-create-temp-tree $temp-directory)

        var omega-path = (path:join $temp-directory omega)

        fs:copy $temp-tree[beta-dir] $omega-path

        os:is-dir $temp-tree[beta-dir] |
          should-be $true

        os:is-dir $omega-path |
          should-be $true

        var omega-content-path = (path:join $omega-path gamma delta)

        slurp < $omega-content-path |
          should-be Delta
      }
    }
  }

  >> 'the move operation' {
    >> 'should move a file' {
      fs:with-temp-file { |sigma-path|
        fs:with-temp-file { |tau-path|
          print Sigma > $sigma-path

          fs:move $sigma-path $tau-path

          os:is-regular $sigma-path |
            should-be $false

          slurp < $tau-path |
            should-be Sigma
        }
      }
    }

    >> 'should move a directory' {
      fs:with-temp-dir { |temp-directory|
        var temp-tree = (-create-temp-tree $temp-directory)

        var omega-path = (path:join $temp-directory omega)

        fs:move $temp-tree[beta-dir] $omega-path

        os:is-dir $temp-tree[beta-dir] |
          should-be $false

        os:is-dir $omega-path |
          should-be $true

        var omega-content-path = (path:join $omega-path gamma delta)

        slurp < $omega-content-path |
          should-be Delta
      }
    }
  }

  >> 'the mkcd command' {
    >> 'when the target directory does not exist' {
      fs:with-temp-dir { |test-root|
        tmp pwd = $test-root

        var components = [alpha beta gamma delta]

        fs:mkcd $@components

        >> 'should create that directory and its parents' {
          path:join $test-root $@components |
            os:is-dir (all) |
            should-be $true
        }

        >> 'should move to that directory' {
          path:base $pwd |
            should-be $components[-1]
        }
      }
    }

    >> 'when the target directory already exists' {
      >> 'should just move to that directory' {
        fs:with-temp-dir { |test-root|
          tmp pwd = $test-root

          var components = [ro sigma tau]

          os:mkdir-all (path:join $@components)

          fs:mkcd $@components

          path:base $pwd |
            should-be $components[-1]
        }
      }
    }
  }

  >> 'opening a file sandbox' {
    >> 'in the end' {
      >> 'if the path existed' {
        >> 'after modification' {
          >> 'should restore the original file' {
            fs:with-temp-file { |test-file|
              var original-content = 'My sample text'
              print $original-content > $test-file

              fs:with-file-sandbox $test-file {
                print ASD > $test-file

                slurp < $test-file |
                  should-be ASD
              }

              slurp < $test-file |
                should-be $original-content
            }
          }
        }

        >> 'after deletion' {
          >> 'should restore the original file' {
            fs:with-temp-file { |test-file|
              fs:with-file-sandbox $test-file {
                os:remove-all $test-file

                os:is-regular $test-file |
                  should-be $false
              }

              os:is-regular $test-file |
                should-be $true
            }
          }
        }
      }

      >> 'if the path did not exist' {
        >> 'should remove the file' {
          var test-file = SOME_INEXISTING_FILE

          fs:with-file-sandbox $test-file {
            echo Some text > $test-file

            os:is-regular $test-file |
              should-be $true
          }

          os:is-regular $test-file |
            should-be $false
        }
      }
    }
  }

  >> 'Opening a directory sandbox' {
    >> 'in the end' {
      >> 'if the path existed' {
        >> 'should restore the tree as it was' {
          fs:with-temp-dir { |temp-dir|
            cd $temp-dir

            var sigma = sigma.txt
            print Sigma > $sigma

            slurp < $sigma |
              should-be Sigma

            var a = A

            var b = (path:join $a B)

            echo 🤯PWD BEFORE SANDBOX: $pwd >&2

            fs:with-dir-sandbox . {
              print LOL > $sigma

              os:mkdir-all $b

              var c = (path:join $b C.txt)
              touch $c

              slurp < $sigma |
                should-be LOL

              os:is-regular $c |
                should-be $true
            }

            echo 🤯PWD AFTER SANDBOX: $pwd >&2

            cd $temp-dir

            echo 🤯PWD AFTER CD: $pwd >&2

            echo LS >&2
            echo 🤯🤯🤯🤯🤯 >&2
            ls -R >&2
            echo 🤯🤯🤯🤯🤯 >&2

            slurp < $sigma |
              should-be Sigma

            os:is-dir $a |
              should-be $false
          }
        }
      }

      >> 'if the path did not exist' {
        >> 'should remove the entire tree' {
          fs:with-temp-dir { |temp-dir|
            cd $temp-dir

            var a = A

            var b = (path:join $a B)

            os:is-dir $a |
              should-be $false

            fs:with-dir-sandbox $a {
              os:mkdir-all $b

              os:is-dir $a |
                should-be $true

              os:is-dir $b |
                should-be $true
            }

            os:is-dir $a |
              should-be $false
          }
        }
      }
    }
  }
}
