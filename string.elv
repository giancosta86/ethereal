use re
use str
use ./lang
use ./set

pragma unknown-command = disallow

#
# Emits every single line received via pipe, prepending the given `prefix` string;
# by default, empty lines are emitted unaltered - unless the `empty-too` option is set.
#
fn prefix-lines { |&empty-too=$false prefix|
  to-lines |
    each { |line|
      if (and (eq $line '') (not $empty-too)) {
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

#
# Converts the input value - of any kind - to a pretty string; more precisely:
#
# * if the value is a string, outputs it.
#
# * if the value is a set from the `set` module, display it as a list.
#
# * if the value is an exception, outputs the call to `show`.
#
# * otherwise, outputs the call to `pprint`.
#
var pretty~ = (
  var formatters-by-kind = [
    &string=$echo~
    &map={ |map|
      if (set:is-set $map) {
        set:to-list $map |
          pprint (all)
      } else {
        pprint $map
      }
    }
    &exception=$show~
  ]

  put { |@arguments|
    var value = (lang:get-single-input $arguments)

    var kind = (kind-of $value)

    var formatter = (
      if (has-key $formatters-by-kind $kind) {
        put $formatters-by-kind[$kind]
      } else {
        put $pprint~
      }
    )

    $formatter $value |
      slurp |
      put (all)[..-1]
  }
)

#
# Escapes every occurrence of the single quote (') by doubling it, as required by Elvish.
#
fn escape-single-quotes { |@arguments|
  var source = (lang:get-single-input $arguments)

  str:replace "'" "''" $source
}