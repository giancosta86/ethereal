use path
use ../seq

pragma unknown-command = disallow

var -which~ = (external which)

var sdkman-home = (path:join ~ .sdkman)

var sdkman-script = (path:join $sdkman-home bin sdkman-init.sh)

var sdk-file = .sdkmanrc

#
# Returns the absolute path of the directory containing the requested SDK.
#
fn get-sdk-directory { |candidate version|
  path:join $sdkman-home candidates $candidate $version
}

#
# Sets up the *_HOME variables for the most frequent binaries in the Java
# ecosystem (Java, Maven, Gradle, sbt); in particular:
#
# * if a binary exists in PATH, the related *_HOME variable is set to its home directory
#
# * otherwise, the environment variable is unset.
#
fn setup-jvm-homes {
  all [
    [java JAVA_HOME]
    [mvn MAVEN_HOME]
    [gradle GRADLE_HOME]
    [sbt SBT_HOME]
  ] | seq:spread { |command home-env-var|
    try {
      -which $command |
        path:dir (all) |
        path:dir (all) |
        set-env $home-env-var (all)
    } catch {
      unset-env $home-env-var
    }
  }
}