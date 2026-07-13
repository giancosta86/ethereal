use os
use path
use ./fs

var this-script-path = (src)[name]

var this-script-dir = (path:dir $this-script-path)

fn create-temp-tree { |temp-root|
  if (not (os:is-dir $temp-root)) {
    fail 'Not an existing directory: '$temp-root
  }

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
  >> 'getting the relative path to a directory' {
    var source-paths = [
      (path:join alpha beta gamma.txt)
      (path:join alpha beta delta epsilon.txt)
      (path:join alpha beta x.txt)
      (path:join ro sigma.txt)
    ]

    var expected-paths-relative-to-beta = [
      gamma.txt
      (path:join delta epsilon.txt)
      x.txt
      (path:join ro sigma.txt)
    ]

    >> 'if the directory prefix ends with path separator' {
      var dir-path = (path:join alpha beta)''$path:separator

      fs:relative-to $dir-path $@source-paths |
        should-emit $expected-paths-relative-to-beta
    }

    >> 'if the directory prefix does not end with path separator' {
      var dir-path = (path:join alpha beta)

      all $source-paths |
        fs:relative-to $dir-path |
        should-emit $expected-paths-relative-to-beta
    }
  }

  >> 'splitting the extension' {
    >> 'when the extension is missing' {
      fs:split-ext alpha |
        should-emit [
          alpha
          ''
        ]
    }

    >> 'when the extension is present' {
      put beta.elv |
        fs:split-ext |
        should-emit [
          beta
          .elv
        ]
    }

    >> 'when there are multiple extensions' {
      fs:split-ext gamma.test.elv |
        should-emit [
          gamma.test
          .elv
        ]
    }
  }

  >> 'switching extension' {
    >> 'when the source path has no extension' {
      fs:switch-ext dodo .png |
          should-be dodo.png
    }

    >> 'when the source path has a single extension' {
      >> 'when the new extension has a leading dot' {
        put alpha.jpg |
          fs:switch-ext .png |
          should-be alpha.png
      }

      >> 'when the new extension has no dot' {
        put alpha.jpg |
          fs:switch-ext png |
          should-be alpha.png
      }
    }

    >> 'when the path has multiple extensions' {
      fs:switch-ext alpha.test.txt elv |
        should-be alpha.test.elv
    }
  }

  >> 'ensuring pwd is not in given directory' {
    var temp-dir = (os:temp-dir)
    defer { os:remove-all $temp-dir }

    var nested-path = (path:join $temp-dir A B C D E)
    os:mkdir-all $nested-path

    cd $nested-path

    fs:ensure-not-in-dir $temp-dir

    put $pwd |
      should-be (path:dir $temp-dir)
  }

  >> 'requesting a temp file path' {
    >> 'should actually create an empty file' {
      var temp-path = (fs:temp-file-path)
      defer { os:remove-all $temp-path }

      put $temp-path |
        should-be-regular

      os:stat $temp-path |
        put (all)[size] |
        should-be 0
    }

    >> 'when not passing a pattern' {
        var temp-path = (fs:temp-file-path)
        defer { os:remove-all $temp-path }

        path:base $temp-path |
          should-have-prefix elvish-
    }

    >> 'when passing a custom pattern' {
      var custom-prefix = alpha-
      var custom-suffix = -omega

      var temp-path = (fs:temp-file-path &pattern=$custom-prefix'*'$custom-suffix)
      defer { os:remove-all $temp-path }

      >> 'should have the requested prefix' {
        path:base $temp-path |
          should-have-prefix $custom-prefix
      }

      >> 'should have the requested suffix' {
        path:base $temp-path |
          should-have-suffix $custom-suffix
      }
    }
  }

  >> 'consuming a temp file path' {
    >> 'should delete the temp path after the consumer runs' {
      var actual-path

      fs:with-temp-file { |temp-path|
        put $temp-path |
          should-be-regular

        set actual-path = $temp-path
      }

      put $actual-path |
        should-not-exist
    }

    >> 'should support a custom pattern' {
      var custom-prefix = alpha-
      var custom-suffix = -omega

      fs:with-temp-file &pattern=$custom-prefix'*'$custom-suffix { |temp-path|
        var temp-base = (path:base $temp-path)

        put $temp-base |
          should-have-prefix $custom-prefix

        put $temp-base |
          should-have-suffix $custom-suffix
      }
    }
  }

  >> 'consuming a temp directory path' {
    >> 'should delete the temp path after the consumer runs' {
      var actual-path

      fs:with-temp-dir { |temp-dir|
        put $temp-dir |
          should-be-dir

        set actual-path = $temp-dir
      }

      put $actual-path |
        should-not-exist
    }

    >> 'should support a custom pattern' {
      var custom-prefix = alpha-
      var custom-suffix = -omega

      fs:with-temp-dir &pattern=$custom-prefix'*'$custom-suffix { |temp-dir|
        var temp-base = (path:base $temp-dir)

        put $temp-base |
          should-have-prefix $custom-prefix

        put $temp-base |
          should-have-suffix $custom-suffix
      }
    }

    >> 'should not automatically move pwd to the created temp directory' {
      fs:with-temp-dir { |temp-dir|
        put $pwd |
          should-not-be $temp-dir
      }
    }

    >> 'should ensure that pwd is out of the created temp directory' {
      var temp-parent

      fs:with-temp-dir { |temp-dir|
        set temp-parent = (path:dir $temp-dir)

        cd $temp-dir

        os:mkdir A
        cd A

        os:mkdir B
        cd B

        os:mkdir C
        cd C
      }

      put $pwd |
        should-be $temp-parent
    }
  }

  >> 'saving a file to any location' {
    >> 'should create intermediate directories' {
      fs:with-temp-dir { |temp-dir|
        var target-path = (path:join $temp-dir alpha beta gamma delta.txt)
        var content = 'Hello, world!'

        put $content |
          fs:save-anywhere $target-path

        slurp < $target-path |
          should-be $content
      }
    }
  }

  >> 'ensuring a file exists' {
    fs:with-temp-file { |temp-path|
      >> 'when the path already exists' {
        >> 'when the path is a actually a file' {
          os:remove-all $temp-path

          print Alpha > $temp-path

          fs:ensure-file $temp-path

          slurp < $temp-path |
            should-be Alpha
        }

        >> 'when the path is not a file' {
          os:remove-all $temp-path

          os:mkdir $temp-path

          fails {
            fs:ensure-file $temp-path
          } |
            should-be 'Path "'$temp-path'" exists, but it is not a file!'
        }
      }

      >> 'when the path does not exist' {
        os:remove-all $temp-path

        fs:ensure-file $temp-path

        put $temp-path |
          should-be-regular
      }
    }
  }

  >> 'cleaning a directory' {
    fs:with-temp-dir { |temp-dir|
      create-temp-tree $temp-dir

      put $temp-dir/*[type:regular] |
        count |
        should-be 1

      put $temp-dir/*[type:dir] |
        count |
        should-be 1

      fs:clean-dir $temp-dir

      >> 'should delete its files' {
        put $temp-dir/*[type:regular][nomatch-ok] |
          count |
          should-be 0
      }

      >> 'should delete its directories' {
        put $temp-dir/*[type:dir][nomatch-ok] |
          count |
          should-be 0
      }

      >> 'should keep the directory itself' {
        put $temp-dir |
          should-be-dir
      }
    }
  }

  >> 'the copy operation' {
    >> 'should copy a file' {
      fs:with-temp-file { |sigma-path|
        fs:with-temp-file { |tau-path|
          print Sigma > $sigma-path

          fs:copy $sigma-path $tau-path

          put $sigma-path |
            should-be-regular

          slurp < $tau-path |
            should-be Sigma
        }
      }
    }

    >> 'should copy a directory' {
      fs:with-temp-dir { |temp-dir|
        var temp-tree = (create-temp-tree $temp-dir)

        var omega-path = (path:join $temp-dir omega)

        fs:copy $temp-tree[beta-dir] $omega-path

        put $temp-tree[beta-dir] |
          should-be-dir

        put $omega-path |
          should-be-dir

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

          put $sigma-path |
            should-not-exist

          slurp < $tau-path |
            should-be Sigma
        }
      }
    }

    >> 'should move a directory' {
      fs:with-temp-dir { |temp-dir|
        var temp-tree = (create-temp-tree $temp-dir)

        var omega-path = (path:join $temp-dir omega)

        fs:move $temp-tree[beta-dir] $omega-path

        put $temp-tree[beta-dir] |
          should-not-exist

        put $omega-path |
          should-be-dir

        var omega-content-path = (path:join $omega-path gamma delta)

        slurp < $omega-content-path |
          should-be Delta
      }
    }
  }

  >> 'the mkcd command' {
    >> 'when the target directory does not exist' {
      fs:with-temp-dir { |temp-dir|
        var components = [alpha beta gamma delta]

        fs:mkcd $temp-dir $@components

        >> 'should create that directory and its parents' {
          path:join $temp-dir $@components |
            should-be-dir
        }

        >> 'should move to that directory' {
          path:base $pwd |
            should-be $components[-1]
        }
      }
    }

    >> 'when the target directory already exists' {
      >> 'should just move to that directory' {
        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          var components = [ro sigma tau]

          os:mkdir-all (path:join $@components)

          fs:mkcd $@components

          path:base $pwd |
            should-be $components[-1]
        }
      }
    }
  }

  >> 'detecting the file system root' {
    >> 'when applied to /' {
      fs:is-root / |
        should-be $true
    }

    >> 'when applied to an intermediate directory' {
      put /dodo |
        fs:is-root |
        should-be $false
    }
  }

  >> 'working in a path sandbox' {
    >> 'when operating on a file' {
      >> 'if the path existed' {
        >> 'after modification' {
          >> 'should restore the original file' {
            fs:with-temp-file { |test-file|
              var original-content = 'My sample text'
              print $original-content > $test-file

              fs:with-path-sandbox $test-file {
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
              fs:with-path-sandbox $test-file {
                os:remove $test-file

                put $test-file |
                  should-not-exist
              }

              put $test-file |
                should-be-regular
            }
          }
        }
      }

      >> 'if the path did not exist' {
        >> 'should remove the file in the end' {
          fs:with-temp-dir { |temp-dir|
            cd $temp-dir

            var test-file = SOME-MISSING-FILE

            fs:with-path-sandbox $test-file {
              echo Some text > $test-file

              put $test-file |
                should-be-regular
            }

            put $test-file |
              should-not-exist
          }
        }
      }
    }

    >> 'when operating on a directory' {
      >> 'if the path existed' {
        >> 'should restore the tree as it was, without altering the pwd' {
          fs:with-temp-dir { |temp-dir|
            cd $temp-dir

            var sigma = sigma.txt
            print Sigma > $sigma

            slurp < $sigma |
              should-be Sigma

            var a = A

            var b = (path:join $a B)

            fs:with-path-sandbox . {
              print LOL > $sigma

              os:mkdir-all $b

              var c = (path:join $b C.txt)
              echo Gamma > $c

              slurp < $sigma |
                should-be LOL

              put $c |
                should-be-regular
            }

            put $pwd |
              should-be $temp-dir

            slurp < $sigma |
              should-be Sigma

            put $a |
              should-not-exist
          }
        }
      }

      >> 'if the path did not exist' {
        >> 'should remove the entire tree' {
          fs:with-temp-dir { |temp-dir|
            cd $temp-dir

            var a = A

            var b = (path:join $a B)

            fs:with-path-sandbox $a {
              put $a |
                should-not-exist

              os:mkdir-all $b

              put $a |
                should-be-dir
            }

            put $a |
              should-not-exist
          }
        }
      }
    }

    >> 'if the path is the file system root' {
        fails {
          fs:with-path-sandbox / { fail 'THIS SHOULD NOT RUN' }
        } |
          should-be 'Cannot apply a sandbox to the file system root!'
      }
  }

  >> 'checking file equality' {
    >> 'when the files are equal' {
      fs:with-temp-dir { |temp-dir|
        echo DODO > alpha.txt
        echo DODO > beta.txt

        put alpha.txt beta.txt |
          fs:equal-files |
          should-be $true
      }
    }

    >> 'when the files are different' {
      fs:with-temp-dir { |temp-dir|
        echo DODO > alpha.txt
        echo CHIPMUNK > beta.txt

        fs:equal-files alpha.txt beta.txt |
          should-be $false
      }
    }
  }

  >> 'finding duplicates' {
    fs:with-temp-dir { |temp-dir|
      cd $temp-dir

      print A > A1
      print A > A2
      print A > A3

      print B > B1
      print B > B2

      os:mkdir-all alpha
      cd alpha
      print A > A4
      print C > C1
      print A > A5
      cd ..

      var duplicate-lists = [(
        put ** |
          fs:find-duplicates |
          order &key=$count~
      )]

      count $duplicate-lists |
        should-be 2

      all $duplicate-lists[0] |
        order |
        should-emit [
          B1
          B2
        ]

      all $duplicate-lists[1] |
        order |
        should-emit [
          A1
          A2
          A3
          alpha/A4
          alpha/A5
        ]
    }
  }

  >> 'finding script files' {
    cd $this-script-dir

    >> 'by default' {
      var actual-scripts = [(fs:find-scripts)]

      put $actual-scripts |
        should-contain fs.elv

      put $actual-scripts |
        should-not-contain fs.test.elv

      put $actual-scripts |
        should-contain tracer/on-off.elv

      put $actual-scripts |
        should-not-contain tracer/on-off.test.elv
    }

    >> 'when including test scripts' {
      var actual-scripts = [(fs:find-scripts &include-tests)]

      put $actual-scripts |
        should-contain fs.elv

      put $actual-scripts |
        should-contain fs.test.elv

      put $actual-scripts |
        should-contain tracer/on-off.elv

      put $actual-scripts |
        should-contain tracer/on-off.test.elv
    }

    >> 'when there are no scripts' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        >> 'when not requesting tests' {
          fs:find-scripts |
            should-emit []
        }

        >> 'when requesting tests' {
          fs:find-scripts &include-tests |
            should-emit []
        }
      }
    }
  }

  >> 'finding test scripts' {
    >> 'in directory with no tests' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        fs:find-test-scripts |
          should-emit []
      }
    }

    >> 'in directory with tests' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        echo alpha > alpha.test.elv
        echo beta > beta.test.elv

        echo omega > omega.elv

        fs:find-test-scripts |
          should-emit &any-order [
            alpha.test.elv
            beta.test.elv
          ]
      }
    }

    >> 'in directory with nested tests' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        echo alpha > alpha.test.elv

        mkdir beta

        echo gamma > (path:join beta gamma.test.elv)

        echo omega > omega.elv

        fs:find-test-scripts |
          should-emit &any-order [
            alpha.test.elv
            (path:join beta gamma.test.elv)
          ]
      }
    }
  }

  >> 'getting script subject' {
    >> 'when the path ends with .elv' {
      fs:get-script-subject 'hello.elv' |
        should-be hello
    }

    >> 'when the path ends with .test.elv' {
      put 'hello.test.elv' |
        fs:get-script-subject |
        should-be hello
    }

    >> 'when the script has yet another extension' {
      fs:get-script-subject 'hello.txt' |
        should-be 'hello.txt'
    }
  }

  >> 'touch command' {
    var brand-new-path = (path:join alpha beta gamma brand-new)

    var existing-file-path = existing-file

    var existing-dir-path = existing-dir

    >> 'when applied to an inexistent path' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        fs:touch $brand-new-path

        put $brand-new-path |
          should-be-regular

        put (os:stat $brand-new-path)[size] |
          should-be 0
      }
    }

    >> 'when applied to an existing file' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        echo Hello > $existing-file-path

        put $existing-file-path |
          fs:touch

        put (os:stat $existing-file-path)[size] |
          should-be 6
      }
    }

    >> 'when applied to an existing dir' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        mkdir $existing-dir-path

        fs:touch $existing-dir-path

        put $existing-dir-path |
          should-be-dir
      }
    }

    >> 'when passing multiple paths' {
      fn scenario { |touch-execution-block|
        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          echo Hello > $existing-file-path

          mkdir $existing-dir-path

          $touch-execution-block

          put $brand-new-path |
            should-be-regular

          to-lines < $existing-file-path |
            should-be Hello

          put $existing-dir-path |
            should-be-dir
        }
      }

      >> 'as arguments' {
        scenario {
          fs:touch $brand-new-path $existing-file-path $existing-dir-path
        }
      }

      >> 'via pipe' {
        scenario {
          all [
            $brand-new-path
            $existing-file-path
            $existing-dir-path
          ] |
            fs:touch
        }
      }
    }
  }

  >> 'getting an external command' {
    >> 'when the external command exists' {
      var command = (
        put cat |
          fs:get-external
      )

      echo Hello |
        $command |
        should-be Hello
    }

    >> 'when the external command does not exist' {
      fs:get-external SOME_INEXISTING_DODO_COMMAND |
        should-be $nil
    }
  }
}
