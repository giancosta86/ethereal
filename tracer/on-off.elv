use ../map
use ../tracer
use ../writer

pragma unknown-command = disallow

#
# Creates a tracer - initially disabled by default - with additional methods:
#
# * enable
#
# * disable
#
# * set-enabled
#
fn create { |&enabled=$false &writer=$writer:out|
  var tracer = (tracer:create { put $enabled } &writer=$writer)

  var controls = [
    &set-enabled={ |value| set enabled = $value }

    &enable={ set enabled = $true }

    &disable={ set enabled = $false }
  ]

  map:merge $tracer $controls
}