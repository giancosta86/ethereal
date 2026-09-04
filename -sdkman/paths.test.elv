use os
use path
use ../lang
use ./paths

>> 'SDKMAN' {
  >> 'paths' {
    >> 'getting a specific SDK path' {
      paths:get-sdk-directory java 25.0.4-tem |
        should-be (path:join $paths:sdkman-home candidates java 25.0.4-tem)
    }

    >> 'setting up the *_HOME environment variables' {
      fn with-temp-candidate { |candidate block|
        fs:within-temp-dir {
          tmp paths:sdkman-home = $pwd

          var candidate-root = (path:join $pwd candidates $candidate)

          os:mkdir-all $candidate-root

          $block $candidate-root
        }
      }

      >> 'when the binaries are in PATH' {
        tmp E:JAVA_HOME = ''

        with-temp-candidate java { |candidate-root|
          var expected-home = (path:join $candidate-root 23-open)

          tmp paths = [
            (path:join $expected-home bin)
          ]

          paths:setup-sdk-homes

          get-env JAVA_HOME |
            should-be $expected-home
        }
      }

      >> 'when the binaries are not in PATH' {
        tmp E:JAVA_HOME = ''
        tmp paths = []

        with-temp-candidate java { |candidate-root|
          paths:setup-sdk-homes

          get-env JAVA_HOME |
            should-be ''
        }
      }
    }
  }
}