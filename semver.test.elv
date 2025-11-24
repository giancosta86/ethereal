use ./semver

var major = 9
var minor = 15
var patch = 7
var pre-release = 'alpha-a.b-c-somethinglong'
var build = 'build.1-aef.1-its-okay'

var full-source = $major'.'$minor'.'$patch'-'$pre-release'+'$build

>> 'In semver module' {
  >> 'parsing a semver' {
    >> 'without the optional leading v' {
      >> 'should parse the major' {
        put $major |
          semver:parse |
          should-be [
            &major=$major
            &minor=0
            &patch=0
            &pre-release=$nil
            &build=$nil
          ]
      }

      >> 'should parse major and minor' {
        put $major'.'$minor |
          semver:parse |
          should-be [
            &major=$major
            &minor=$minor
            &patch=0
            &pre-release=$nil
            &build=$nil
          ]
      }

      >> 'should parse major, minor and patch' {
        put $major'.'$minor'.'$patch |
          semver:parse |
          should-be [
            &major=$major
            &minor=$minor
            &patch=$patch
            &pre-release=$nil
            &build=$nil
          ]
      }

      >> 'should parse major, minor, patch and pre-release' {
        put $major'.'$minor'.'$patch'-'$pre-release |
          semver:parse |
          should-be [
            &major=$major
            &minor=$minor
            &patch=$patch
            &pre-release=$pre-release
            &build=$nil
          ]
      }

      >> 'should parse major, minor, patch and build' {
        put $major'.'$minor'.'$patch'+'$build |
          semver:parse |
          should-be [
            &major=$major
            &minor=$minor
            &patch=$patch
            &pre-release=$nil
            &build=$build
          ]
      }

      >> 'should parse all the components' {
        put $full-source |
          semver:parse |
          should-be [
            &major=$major
            &minor=$minor
            &patch=$patch
            &pre-release=$pre-release
            &build=$build
          ]
      }
    }

    >> 'with the optional leading v' {
      >> 'should parse all the components' {
        put 'v'$full-source |
          semver:parse |
          should-be [
            &major=$major
            &minor=$minor
            &patch=$patch
            &pre-release=$pre-release
            &build=$build
          ]
      }
    }
  }

  >> 'converting to string' {
    >> 'when there is only major' {
      semver:parse $major |
        semver:to-string |
        should-be $major'.0.0'
    }

    >> 'when there are major and minor' {
      semver:parse $major'.'$minor |
        semver:to-string |
        should-be $major'.'$minor'.0'
    }

    >> 'when there are major, minor and patch' {
      var source = $major'.'$minor'.'$patch

      semver:parse $source |
        semver:to-string |
        should-be $source
    }

    >> 'when there are major, minor, patch and pre-release' {
      var source = $major'.'$minor'.'$patch'-'$pre-release

      semver:parse $source |
        semver:to-string |
        should-be $source
    }

    >> 'when there are major, minor, patch and build' {
      var source = $major'.'$minor'.'$patch'+'$build

      semver:parse $source |
        semver:to-string |
        should-be $source
    }

    >> 'when there are all the components' {
      semver:parse $full-source |
        semver:to-string |
        should-be $full-source
    }
  }

  >> 'detecting stability' {
    >> 'for stable version' {
      semver:parse $major'.'$minor'.'$patch |
        semver:is-stable |
        should-be $true
    }

    >> 'for version with pre-release' {
      semver:parse $major'.'$minor'.'$patch'-'$pre-release |
        semver:is-stable |
        should-be $false
    }

    >> 'for version with build' {
      semver:parse $major'.'$minor'.'$patch'+'$build |
        semver:is-stable |
        should-be $false
    }

    >> 'for version with pre-release and build' {
      semver:parse $major'.'$minor'.'$patch'-'$pre-release'+'$build |
        semver:is-stable |
        should-be $false
    }
  }

  >> 'detecting new major' {
    >> 'for new stable version' {
      semver:parse $major'.0.0' |
        semver:is-new-major |
        should-be $true
    }

    >> 'for new unstable version' {
      semver:parse $major'.0.0-'$pre-release |
        semver:is-new-major |
        should-be $false
    }
  }

  >> 'ordering versions' {
    all [
      (semver:parse 4.5.2)
      (semver:parse 3.2.1)
      (semver:parse 3.2.1-beta-1)
      (semver:parse 1.0.0)
      (semver:parse 4.5.1)
      (semver:parse 3.2.1-beta-2)
      (semver:parse 4.5.0)
    ] |
      order &less-than=$semver:less-than~ |
      put [(all)] |
      should-be [
        (semver:parse 1.0.0)
        (semver:parse 3.2.1-beta-1)
        (semver:parse 3.2.1-beta-2)
        (semver:parse 3.2.1)
        (semver:parse 4.5.0)
        (semver:parse 4.5.1)
        (semver:parse 4.5.2)
      ]
  }
}
