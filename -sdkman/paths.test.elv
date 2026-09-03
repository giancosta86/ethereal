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
      >> 'when a candidate has a current version set' {
        tmp E:JAVA_HOME = ''

        fs:within-temp-dir {
          tmp paths:sdkman-home = $pwd

          var java-candidate-dir = (path:join $pwd candidates java)

          var some-version-dir = (path:join $java-candidate-dir 23-open)

          os:mkdir-all $some-version-dir

          var current-link-path = (path:join $java-candidate-dir current)

          os:symlink $some-version-dir $current-link-path

          paths:setup-jvm-homes

          get-env JAVA_HOME |
            should-be $current-link-path
        }
      }

      >> 'when a candidate has no current version' {
        tmp E:JAVA_HOME = ''

        fs:within-temp-dir {
          tmp paths:sdkman-home = $pwd

          var java-candidate-dir = (path:join $pwd candidates java)

          var some-version-dir = (path:join $java-candidate-dir 23-open)

          os:mkdir-all $some-version-dir

          paths:setup-jvm-homes

          get-env JAVA_HOME |
            should-be-empty
        }
      }

      >> 'when a candidate is not installed' {
        tmp E:JAVA_HOME = ''

        fs:within-temp-dir {
          tmp paths:sdkman-home = $pwd

          paths:setup-jvm-homes

          get-env JAVA_HOME |
            should-be-empty
        }
      }
    }
  }
}