use ./semver

>> 'In semver module' {
  >> 'parsing a semver' {
    >> 'with all the components' {
      var major = 9
      var minor = 15
      var patch = 7
      var pre-release = 'alpha-a.b-c-somethinglong'
      var build = 'build.1-aef.1-its-okay'

      var source = $major'.'$minor'.'$patch'-'$pre-release'+'$build

      >> 'without the optional leading v' {
        >> 'should parse all the components' {
          var semver = (semver:parse $source)

          put $semver[major] |
            should-be $major

          put $semver[minor] |
            should-be $minor

          put $semver[patch] |
            should-be $patch

          put $semver[pre-release] |
            should-be $pre-release

          put $semver[build] |
            should-be $build
        }
      }

      >> 'with the optional leading v' {
        >> 'should parse all the components' {
          var semver = (semver:parse 'v'$source)

          put $semver[major] |
            should-be $major

          put $semver[minor] |
            should-be $minor

          put $semver[patch] |
            should-be $patch

          put $semver[pre-release] |
            should-be $pre-release

          put $semver[build] |
            should-be $build
        }
      }
    }

    >> 'with just the major component' {
      var major = 4
      var semver = (semver:parse $major)

      >> 'should have the major component' {
        put $semver[major] |
          should-be $major
      }

      >> 'should have minor and patch set to 0' {
        put $semver[minor] |
          should-be 0

        put $semver[patch] |
          should-be 0
      }

      >> 'should have pre-release and build set to $nil' {
        put $semver[pre-release] |
          should-be $nil

        put $semver[build] |
          should-be $nil
      }
    }
  }
}
