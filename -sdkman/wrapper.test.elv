use os
use path
use ./paths
use ./test-shared
use ./wrapper

>> 'SDKMAN' {
  >> 'wrapper' {
    >> 'requesting the version' {
      capture {
        wrapper:sdk version
      } |
        should-contain SDKMAN
    }
  }

  >> 'PATH-altering commands' {
    tmp wrapper:-run-sdkman~ = { |@arguments| }

    >> 'use' {
      tmp paths = [X]
      tmp E:JAVA_HOME = DODO

      test-shared:within-temp-sdkman-home {
        test-shared:install java 23-open &bin

        wrapper:sdk use java 23-open

        all $paths |
          should-emit [
            (test-shared:get-path-entry java 23-open &bin)
            X
          ]

        get-env JAVA_HOME |
          should-be (paths:get-candidate-dir java &version=23-open)
      }
    }

    fn test-env-loading { |sdk-invocation-block|
      tmp paths = [X]
      tmp E:JAVA_HOME = yogi
      tmp E:MAVEN_HOME = bubu

      test-shared:within-temp-sdkman-home {
        test-shared:install java 23-open &bin

        test-shared:install maven 3.9.9 &bin

        fs:within-temp-dir {
          {
            echo java=8.0.502.fx-zulu
            echo maven=3.3.9
          } > $paths:sdk-file

          #Simulating the effects of the env loading
          {
            test-shared:install java 8.0.502.fx-zulu &bin &current=$false
            test-shared:install maven 3.3.9 &bin &current=$false
          }

          $sdk-invocation-block

          all $paths |
            should-emit &any-order [
              (test-shared:get-path-entry java 8.0.502.fx-zulu &bin)
              (test-shared:get-path-entry maven 3.3.9 &bin)
              X
            ]

          get-env JAVA_HOME |
            should-be (paths:get-candidate-dir java &version=8.0.502.fx-zulu)

          get-env MAVEN_HOME |
            should-be (paths:get-candidate-dir maven &version=3.3.9)
        }
      }
    }

    >> 'env' {
      test-env-loading {
        wrapper:sdk env
      }
    }

    >> 'env install' {
      test-env-loading {
        wrapper:sdk env install
      }
    }

    >> 'env clear' {
      test-shared:within-temp-sdkman-home {
        test-shared:install java 8.0.502.fx-zulu &bin

        # Simulating an SDK installed because of the .sdkmanrc file
        {
          test-shared:install java 23-open &current=$false
        }

        tmp paths = [
          (test-shared:get-path-entry java 23-open)
        ]

        tmp E:JAVA_HOME = (paths:get-candidate-dir java &version=23-open)

        wrapper:sdk env clear

        all $paths |
          should-emit &any-order [
            (test-shared:get-current-link java &bin)
          ]

        get-env JAVA_HOME |
          should-be (test-shared:get-current-link java)
      }
    }
  }
}