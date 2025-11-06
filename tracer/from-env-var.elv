use ../set
use ../tracer

var -enabled-values = (set:of true '$true' t 1)

fn create { |env-var-name|
  tracer:create {
    if (has-env $env-var-name) {
      get-env $env-var-name |
        set:has-value $-enabled-values (all)
    } else {
      put $false
    }
  }
}