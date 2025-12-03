pragma unknown-command = disallow

var -jq~ = (external jq)

#
# Reads the entire content of the given `path` and passes it to `transformer`,
# which must be a function taking such content and returning either the new content or $nil.
#
# If the returned value is not $nil, it replaces the original file content.
#
fn file { |path transformer|
  var updated-content = (
    slurp < $path |
      $transformer (all) |
      one
  )

  if (not-eq $updated-content $nil) {
    print $updated-content > $path
  }
}

#
# In-place manipulation of the given `path` using the **jq** command, passing the given arguments:
# the operation is performed without creating an auxiliary temp file.
#
fn json { |path @jq-arguments|
  -jq $@jq-arguments < $path |
    slurp |
    to-lines > $path
}