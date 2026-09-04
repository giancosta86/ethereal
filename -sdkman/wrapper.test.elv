use path
use ./paths
use ./wrapper

var sdk~ = $wrapper:sdk~

>> 'SDKMAN' {
  >> 'wrapper' {
    >> 'requesting the version' {
      capture {
        sdk version
      } |
        should-contain SDKMAN
    }

    >> 'installing and using from an SDK file' {
      var test-dependencies = [
        bash # Required to run SDKMAN
        cp # Used by file-system utilities
      ]

      tmp paths = [
        (
          all $test-dependencies |
            each (external which) |
            each $path:dir~
        )
      ]

      fs:within-temp-dir {
        echo 'ant=1.9.10' > $paths:sdk-file

        var expected-path-entry = (
          paths:get-sdk-directory ant current |
            path:join (all) bin
        )

        sdk env install

        put $paths |
          should-not-contain $expected-path-entry

        sdk env use

        put $paths |
          should-contain $expected-path-entry
      }
    }
  }
}