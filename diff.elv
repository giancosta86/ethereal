use os
use ./fs

var -diff~ = (external diff)

#
# Outputs the unified, coloured diff between the `print` output of two values, using the `diff` system command;
# in case of errors - for example if the command is not available - just does nothing, unless
# the `throw` flag is set.
#
fn diff { |&throw=$false left right|
  var left-path = (fs:temp-file-path)
  defer { os:remove-all $left-path }

  var right-path = (fs:temp-file-path)
  defer { os:remove-all $right-path }

  var exception = $nil

  print $left > $left-path
  print $right > $right-path

  try {
    -diff --color=always --unified $left-path $right-path
  } catch e {
    set exception = $e
  }

  if (and $exception $throw) {
    fail $exception
  }
}