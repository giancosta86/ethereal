use os
use path
use ./paths
use ./test-shared

>> 'SDKMAN' {
  >> 'paths' {
    >> 'getting a specific candidate directory' {
      >> 'when the version is not passed' {
        paths:get-candidate-dir java |
          should-be (path:join $paths:sdkman-home candidates java)
      }

      >> 'when the version is passed' {
        paths:get-candidate-dir java &version=25.0.4-tem |
          should-be (path:join $paths:sdkman-home candidates java 25.0.4-tem)
      }
    }

    >> 'iterating over the candidates' {
      >> 'when there is not even a candidate hub directory' {
        test-shared:within-temp-sdkman-home {
          paths:each-candidate $put~ |
            should-emit []
        }
      }

      >> 'when there are candidates' {
        test-shared:within-temp-sdkman-home {
          test-shared:install alpha 1.0

          test-shared:install beta 7.4

          test-shared:install gamma 3.2

          paths:each-candidate { |candidate|
            echo 📁 $candidate
          } |
          should-emit &any-order [
            '📁 alpha'
            '📁 beta'
            '📁 gamma'
          ]
        }
      }
    }

    >> 'getting a *_HOME environment variable name' {
      paths:get-candidate-home-var java |
        should-be JAVA_HOME
    }

    >> 'getting a *_HOME path' {
      >> 'when the path ends with "bin"' {
        var expected-home = (path:join alpha beta gamma)

        path:join $expected-home bin |
          paths:-get-home-path |
          should-be $expected-home
      }

      >> 'when the path does not end with "bin"' {
        var expected-home = (path:join alpha beta gamma)

        paths:-get-home-path $expected-home |
          should-be $expected-home
      }
    }

    >> 'setting up the *_HOME environment variable for a candidate' {
      >> 'when the candidate is not in PATH' {
        tmp paths = [X]
        tmp E:JAVA_HOME = DODO

        test-shared:within-temp-sdkman-home {
          test-shared:install java 23-open

          paths:-setup-candidate-home java

          has-env JAVA_HOME |
            should-be $false
        }
      }
      >> 'when the candidate is in PATH' {
        >> 'when the PATH entry ends with "bin"' {
          tmp E:JAVA_HOME = DODO

          test-shared:within-temp-sdkman-home  {
            tmp paths = [
              A
              B
              (test-shared:get-path-entry java 23-open &bin)
              C
            ]

            paths:-setup-candidate-home java

            get-env JAVA_HOME |
              should-be (paths:get-candidate-dir java &version=23-open)
          }
        }

        >> 'when the PATH entry does not end with "bin"' {
          tmp E:JAVA_HOME = YOGI

          test-shared:within-temp-sdkman-home {
            var expected-home = (paths:get-candidate-dir java &version=23-open)

            tmp paths = [
              X
              Y
              $expected-home
              Z
            ]

            paths:-setup-candidate-home java

            get-env JAVA_HOME |
              should-be $expected-home
          }
        }
      }
    }

    >> 'setting up all the *_HOME environment variables' {
      >> 'when the binaries are in PATH' {
        tmp E:JAVA_HOME = YOGI
        tmp E:MAVEN_HOME = BUBU

        test-shared:within-temp-sdkman-home {
          test-shared:install java 23-open
          test-shared:install maven 3.9.9 &bin

          tmp paths = [
            A
            B
            (test-shared:get-path-entry maven 3.9.9 &bin)
            C
            (test-shared:get-path-entry java 23-open)
            D
            E
          ]

          paths:setup-sdk-homes

          get-env JAVA_HOME |
            should-be (paths:get-candidate-dir java &version=23-open)

          get-env MAVEN_HOME |
            should-be (paths:get-candidate-dir maven &version=3.9.9)
        }
      }

      >> 'when the binaries are not in PATH' {
        tmp E:JAVA_HOME = YOGI
        tmp E:MAVEN_HOME = BUBU

        tmp paths = [X]

        test-shared:within-temp-sdkman-home &candidates=[java maven] {
          paths:setup-sdk-homes

          has-env JAVA_HOME |
            should-be $false

          has-env MAVEN_HOME |
            should-be $false
        }
      }
    }

    >> 'getting candidates from SDK file' {
      >> 'when no SDK file exists' {
        fs:within-temp-dir {
          paths:get-sdkfile-candidates |
            should-be [&]
        }
      }

      >> 'when the SDK file is empty' {
        fs:within-temp-dir {
          fs:touch $paths:sdk-file

          paths:get-sdkfile-candidates |
            should-be [&]
        }
      }

      >> 'when the SDK file contains SDKs as well as comments' {
        fs:within-temp-dir {
          {
            echo '# This is a temp SDK file'
            echo
            echo 'java=ALPHA'
            echo '    maven =  BETA  '
            echo
            echo "gradle\t=\tGAMMA"
          } > $paths:sdk-file

          paths:get-sdkfile-candidates |
            should-be [
              &java=ALPHA
              &maven=BETA
              &gradle=GAMMA
            ]
        }
      }
    }

    >> 'getting the PATH reset to the current candidates' {
      >> 'when there are no candidates with existing dirs' {
        test-shared:within-temp-sdkman-home {
          tmp paths = [
            X
            (path:join $pwd candidates dodo)
            Y
            (path:join $pwd candidates yogi)
            Z
          ]

          paths:-get-reset |
            should-emit [
              X
              Y
              Z
            ]
        }
      }

      >> 'when there are candidates with existing dirs' {
        test-shared:within-temp-sdkman-home {
          tmp paths = [
            X
            (paths:get-candidate-dir yogi)
            Y
            Z
          ]

          test-shared:install java 23-open

          test-shared:install maven 3.9.9 &bin

          paths:-get-reset |
            should-emit &any-order [
              (test-shared:get-current-link java)
              (test-shared:get-current-link maven &bin)
              X
              Y
              Z
            ]
        }
      }

      >> 'when overriding versions are passed' {
        test-shared:within-temp-sdkman-home {
          tmp paths = [
            X
            (paths:get-candidate-dir yogi)
            Y
            Z
          ]

          {
            test-shared:install java 23-open

            test-shared:install maven 3.9.9
          }

          {
            test-shared:install java 8.0.502.fx-zulu &current=$false

            test-shared:install maven 3.3.9 &current=$false
          }

          paths:-get-reset &overriding-versions=[
            &java=8.0.502.fx-zulu
            &maven=3.3.9
          ] |
            should-emit &any-order [
              (paths:get-candidate-dir java &version=8.0.502.fx-zulu)
              (paths:get-candidate-dir maven &version=3.3.9)
              X
              Y
              Z
            ]
        }
      }
    }

    >> 'resetting the PATH and the *_HOME variables' {
      tmp E:JAVA_HOME = alpha
      tmp E:MAVEN_HOME = beta
      tmp E:YOGI_HOME = gamma

      test-shared:within-temp-sdkman-home &candidates=[yogi] {
        tmp paths = [
          X
          (paths:get-candidate-dir yogi &version=14.2)
          Y
          Z
        ]

        {
          test-shared:install java 23-open

          test-shared:install maven 3.9.9 &bin
        }

        {
          test-shared:install java 8.0.502.fx-zulu &current=$false

          test-shared:install maven 3.3.9 &bin &current=$false
        }

        paths:reset-vars &overriding-versions=[
          &java=8.0.502.fx-zulu
          &maven=3.3.9
        ]

        >> 'should update PATH' {
          all $paths |
            should-emit &any-order [
              (test-shared:get-path-entry java 8.0.502.fx-zulu)
              (test-shared:get-path-entry maven 3.3.9 &bin)
              X
              Y
              Z
            ]
        }

        >> 'should update *_HOME env variables' {
          get-env JAVA_HOME |
            should-be (paths:get-candidate-dir java &version=8.0.502.fx-zulu)

          get-env MAVEN_HOME |
            should-be (paths:get-candidate-dir maven &version=3.3.9)

          has-env YOGI_HOME |
            should-be $false
        }
      }
    }
  }
}