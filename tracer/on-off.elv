use ../map
use ../tracer

#TODO! Test the flag!
fn create { |&enabled=$false|
  var tracer = (tracer:create { put $enabled })

  var controls = [
    &set-enabled={ |value| set enabled = $value }

    &enable={ set enabled = $true }

    &disable={ set enabled = $false }
  ]

  map:merge $tracer $controls
}