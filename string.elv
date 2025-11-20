use re
use ./lang

#
# Emits every single line it receives via pipe, prepending the given `prefix` string;
# by default, empty lines are emitted unaltered - unless the `empty-too` flag is set.
#
fn prefix-lines { |&empty-too=$false prefix|
  to-lines |
    each { |line|
      if (and (not $empty-too) (eq $line '')) {
        echo
      } else {
        echo $prefix''$line
      }
    }
}

#
# Removes every style modifier from the given string - therefore reversing every effect
# induced by `styled`.
#
fn unstyled { |@arguments|
  lang:get-single-input $arguments |
    re:replace '\x1b\[[0-9;]*m' '' (all)
}

var -pretty-formatters-by-kind = [
  &string=$echo~
  &exception=$show~
]

#
# Converts any value to a pretty string; more precisely:
#
# * if the value is a string, outputs it.
#
# * if the value is an exception, outputs the call to `show`.
#
# * otherwise, outputs the call to `pprint`.
#
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
    slurp |
    put (all)[..-1]
}