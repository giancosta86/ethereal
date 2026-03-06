use str
use ./lang
use ./writer

pragma unknown-command = disallow

#
# Creates a tracer - an object containing the following methods:
#
# * `echo`
#
# * `print`
#
# * `printf`
#
# * `pprint`
#
# * `inspect`: prints the given emoji and the given description, then pretty-prints the given value.
#
# * `inspect-input-map`: calls `inspect` to display a map used as input.
#
# * `section`: shows the given emoji and the given description, then goes to a new line and:
#
#   * if the last argument is a string, echoes it.
#
#   * if the last argument is a function, calls it.
#
#   Finally, outputs 3 times the given emoji, to mark the end of the section.
#
# This constructor takes 2 parameter:
#
# * whether the tracer's methods actually output; it can be either a boolean value or a function
#   that will be called every time.
#
# * a writer - a function taking a block and redirecting it somewhere; in particular:
#
#   * `$writer:out` - redirects to stdout (the default).
#
#   * `$writer:err` - redirects to stderr.
#
#   * `writer:to-file` - takes a file (object or path) and returns a writer appending to it.
#
fn create { |&writer=$writer:out @arguments|
  var enabled = (lang:get-single-input $arguments)

  fn trace { |block|
    if (lang:resolve $enabled) {
      $writer $block
    } else {
      # Just do nothing
    }
  }

  fn inspect { |&emoji=🔎 description @arguments|
    var value = (lang:get-single-input $arguments)

    trace {
      printf '%s %s: ' $emoji $description

      pprint $value
    }
  }

  put [
    &echo={ |@arguments|
      trace {
        echo $@arguments
      }
    }

    &print={ |@arguments|
      trace {
        print $@arguments
      }
    }

    &printf={ |&newline=$false template @values|
      trace {
        printf $template $@values

        if $newline {
          echo
        }
      }
    }

    &pprint={ |@arguments|
      trace {
        pprint $@arguments
      }
    }

    &inspect=$inspect~

    &inspect-input-map={ |@arguments|
      var input-map = (lang:get-single-input $arguments)

      inspect &emoji=📥 'Input map' $input-map
    }

    &section={ |&emoji=🔎 description @arguments|
      var string-or-block = (lang:get-single-input $arguments)

      trace {
        echo $emoji' '$description":"

        if (lang:is-function $string-or-block) {
          $string-or-block
        } else {
          echo $string-or-block
        }

        echo (str:repeat $emoji 3)
      }
    }
  ]
}
