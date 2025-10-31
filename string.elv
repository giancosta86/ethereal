use re
use ./lang

fn indent-lines { |indent|
  var slurp-result = (
    to-lines |
      each { |line|
        if (eq $line '') {
          echo
        } else {
          echo $indent''$line
        }
      } |
      slurp
  )

  put $slurp-result[..-1]
}

fn unstyled { |@arguments|
  lang:get-single-input $arguments |
    re:replace '\x1b\[[0-9;]*m' '' (all)
}

var -pretty-formatters-by-kind = [
  &string=$echo~
  &exception=$show~
]

fn pretty { |@arguments|
  var value = (lang:get-single-input $arguments)

  var kind = (kind-of $value)

  var formatter = (
    if (has-key $-pretty-formatters-by-kind $kind) {
      put $-pretty-formatters-by-kind[$kind]
    } else {
      put $pprint~
    }
  )

  $formatter $value |
    slurp
}