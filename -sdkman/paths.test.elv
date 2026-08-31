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
      >> 'when the binaries are in PATH' {
        var expected-java-home = FAKE-JAVA-HOME
        var expected-maven-home = FAKE-MAVEN-HOME
        var expected-gradle-home = FAKE-GRADLE-HOME
        var expected-sbt-home = FAKE-SBT-HOME

        tmp paths:-which~ = { |command|
          put $command | lang:switch [
            &java={
              path:join $expected-java-home bin java
            }
            &mvn={
              path:join $expected-maven-home bin mvn
            }
            &gradle={
              path:join $expected-gradle-home bin gradle
            }
            &sbt={
              path:join $expected-sbt-home bin sbt
            }
          ]
        }

        tmp E:JAVA_HOME = ''
        tmp E:MAVEN_HOME = ''
        tmp E:GRADLE_HOME = ''
        tmp E:SBT_HOME = ''

        paths:setup-jvm-homes

        get-env JAVA_HOME |
          should-be $expected-java-home

        get-env MAVEN_HOME |
          should-be $expected-maven-home

        get-env GRADLE_HOME |
          should-be $expected-gradle-home

        get-env SBT_HOME |
          should-be $expected-sbt-home
      }

      >> 'when the binaries are not in PATH' {
        tmp E:JAVA_HOME = 'A'
        tmp E:MAVEN_HOME = 'B'
        tmp E:GRADLE_HOME = 'C'
        tmp E:SBT_HOME = 'D'

        tmp paths:-which~ = { |command|
          fail 'No path found'
        }

        paths:setup-jvm-homes

        all [
          JAVA_HOME
          MAVEN_HOME
          GRADLE_HOME
          SBT_HOME
        ] | each { |home-env-var|
          has-env $home-env-var |
            should-be $false
        }
      }
    }
  }
}