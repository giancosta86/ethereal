use path
use str
use ./resources

>> 'In resources module' {
  >> 'retrieving a resource' {
    >> 'when passing inputs as arguments' {
      var resources = (resources:for-script (src))

      var license-path = ($resources[get-path] LICENSE)

      var license-content = (slurp < $license-path)

      str:contains $license-content Copyright |
        should-be $true
    }

    >> 'when passing inputs via pipe' {
      var resources = (src | resources:for-script)

      var license-path = (
        put LICENSE |
          $resources[get-path]
      )

      var license-content = (slurp < $license-path)

      str:contains $license-content Copyright |
        should-be $true
    }

    >> 'should return an absolute path' {
      var resources = (src | resources:for-script)

      $resources[get-path] LICENSE |
        path:is-abs (all) |
        should-be $true
    }
  }
}
