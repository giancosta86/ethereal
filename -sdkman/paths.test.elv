use path
use ./paths
use ./test-shared

>> 'SDKMAN' {
  >> 'paths' {
    >> 'getting a specific SDK path' {
      paths:get-sdk-directory java 25.0.4-tem |
        should-be (path:join $paths:sdkman-home candidates java 25.0.4-tem)
    }

    >> 'getting a *_HOME environment variable name' {
      paths:get-candidate-home-var java |
        should-be JAVA_HOME
    }

    >> 'setting up the *_HOME environment variables' {
      >> 'when the binaries are in PATH' {
        tmp E:JAVA_HOME = ''

        test-shared:with-temp-candidate java { |candidate-root|
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

        test-shared:with-temp-candidate java { |candidate-root|
          paths:setup-sdk-homes

          get-env JAVA_HOME |
            should-be ''
        }
      }
    }
  }
}