use str
use ./lang

pragma unknown-command = disallow

fn -trace { |enabled writer block|
  if (lang:resolve $enabled) {
    $writer $block
  }
}

#
# Takes a block and redirects its out to stdout.
#
var out-writer = { |block| $block }

#
# Takes a block and redirects its out to stderr.
#
var err-writer = { |block| $block > &2 }

#
# Creates a writer that takes a block and appends its out to the given file (object or path).
#
fn create-file-writer { |file|
  put { |block| $block >> $file }
}

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
# * `section`: shows the given emoji and the given description, then:
#
#   * if the last argument is a string, echoes it.
#
#   * if the last argument is a function, calls it.
#
#   Finally, outputs 3 times the given emoji, to mark the end of the section
#
# This constructor takes 2 parameter:
#
# * whether the tracer's methods actually output; it can be either a boolean value or a function
#   that will be called every time.
#
# * a writer - a function taking a block and redirecting it somewhere; in particular:
#
#   * `$tracer:out-writer` - redirects to stdout (the default).
#
#   * `$tracer:err-writer` - redirects to stderr.
#
#   * `create-file-writer` - takes a file (object or path) and returns a writer appending to it.
#
fn create { |enabled &writer=$out-writer|
  fn inspect { |&emoji=🔎 description value|
    -trace $enabled $writer {
      printf '%s %s: ' $emoji $description

      pprint $value
    }
  }

  put [
    &echo={ |@arguments|
      -trace $enabled $writer {
        echo $@arguments
      }
    }

    &print={ |@arguments|
      -trace $enabled $writer {
        print $@arguments
      }
    }

    &printf={ |&newline=$false template @values|
      -trace $enabled $writer {
        printf $template $@values

        if $newline {
          echo
        }
      }
    }

    &pprint={ |@values|
      -trace $enabled $writer {
        pprint $@values
      }
    }

    &inspect=$inspect~

    &inspect-input-map={ |input-map|
      inspect &emoji=📥 'Input map' $input-map
    }

    &section={ |&emoji=🔎 description string-or-block|
      -trace $enabled $writer {
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
