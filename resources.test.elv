use path
use ./resources

>> 'In resources module' {
  >> 'retrieving a resource' {
    >> 'when passing inputs as arguments to both functions' {
      var resources = (resources:for-script (src))

      var license-path = ($resources[get-path] LICENSE)

      slurp < $license-path |
        should-contain Copyright
    }

    >> 'when passing inputs via pipe to both functions' {
      var resources = (src | resources:for-script)

      var license-path = (
        put LICENSE |
          $resources[get-path]
      )

      slurp < $license-path |
        should-contain Copyright
    }

    >> 'should return an absolute path' {
      var resources = (src | resources:for-script)

      $resources[get-path] LICENSE |
        path:is-abs (all) |
        should-be $true
    }
  }
}
