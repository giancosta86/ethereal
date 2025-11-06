use path
use ../fs
use ./node-version

var initial-version = v13.0.0

var nvmrc-version = v18.17.1

var package-json-version = v16.14.0

fn -write-nvmrc-file {
  echo $nvmrc-version > .nvmrc
}

fn -write-package-json-file {
  var version-for-json = $package-json-version[1..]

  echo '{ "engines": { "node": ">='$version-for-json' <90" }}' > package.json
}

>> 'Retrieving the requested NodeJS version' {
  >> 'from a directory containing only .nvmrc' {
    >> 'should emit such version' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        -write-nvmrc-file

        node-version:detect-in-pwd |
          should-be $nvmrc-version
      }
    }
  }

  >> 'from a directory containing only package.json field' {
    >> 'should emit such version' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        -write-package-json-file

        node-version:detect-in-pwd |
          should-be $package-json-version
      }
    }
  }

  >> 'from a directory containing both .nvmrc and package.json field' {
    >> 'should emit the version in .nvmrc' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        -write-nvmrc-file
        -write-package-json-file

        node-version:detect-in-pwd |
          should-be $nvmrc-version
      }
    }
  }

  >> 'from a directory not directly containing such information' {
    >> 'when an ancestor directory contains .nvmrc' {
      >> 'should emit such version' {
        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          -write-nvmrc-file

          path:join A B C D |
            fs:mkcd (all)

          node-version:detect-in-pwd |
            should-be $nil

          node-version:detect-recursively |
            should-be $nvmrc-version
        }
      }
    }

    >> 'when an ancestor directory contains only package.json field' {
      >> 'should emit such version' {
        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          -write-package-json-file

          path:join A B C D |
            fs:mkcd (all)

          node-version:detect-in-pwd |
            should-be $nil

          node-version:detect-recursively |
            should-be $package-json-version
        }
      }
    }

    >> 'when an ancestor directory contains both .nvmrc and package.json field' {
      >> 'should emit the version in .nvmrc' {
        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          -write-nvmrc-file
          -write-package-json-file

          path:join A B C D |
            fs:mkcd (all)

          node-version:detect-in-pwd |
            should-be $nil

          node-version:detect-recursively |
            should-be $nvmrc-version
        }
      }
    }
  }
}