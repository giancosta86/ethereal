use ../tracer

pragma unknown-command = disallow

var -enabled-values = [true '$true' t 1]

#
# Creates a tracer enabled only when the given environment variable assumes one
# of the "enabled" values.
#
fn create { |env-var-name &writer=$tracer:out-writer|
  fn enabled-by-var {
    if (has-env $env-var-name) {
      get-env $env-var-name |
        has-value $-enabled-values (all)
    } else {
      put $false
    }
  }

  tracer:create $enabled-by-var~ &writer=$writer
}