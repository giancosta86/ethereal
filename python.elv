use ./lang

pragma unknown-command = disallow

var -pip~ = (external pip)

#
# Downloads the given package - passed via pipe or as argument - from PyPI.
#
# If &version is not passed, the latest will be assumed.
#
# The binary package is downloaded - whereas the &sources flag will download the source archive instead.
#
fn download-package { |&sources=$false &version=$nil @arguments|
  var package = (lang:get-single-input $arguments)

  var package-reference = (
    if $version {
      put $package'=='$version
    } else {
      put $package
    }
  )

  var sources-args = (
    if $sources {
      put [
        --no-binary
        :all:
      ]
    } else {
      put []
    }
  )

  -pip download --no-deps $@sources-args $package-reference
}

#
# Enables memory allocation tracing - which is especially useful
# when running tests with leaking objects and unreleased resources.
#
fn trace-malloc {
  set-env PYTHONTRACEMALLOC 1
}