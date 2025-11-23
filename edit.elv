#
# Reads the entire content of the given `file` and passes it to `transformer`,
# which must be a function taking such content and returning either the new content or $nil.
#
# If the returned value is not $nil, it replaces the original file content.
#
fn file { |file transformer|
  var updated-content = (
    slurp < $file |
      $transformer (all) |
      one
  )

  if (not-eq $updated-content $nil) {
    print $updated-content > $file
  }
}

#
# In-place manipulation of the given `file` using the **jq** command, passing the given arguments:
# the operation is performed without creating an auxiliary temp file.
#
fn json { |file @jq-arguments|
    jq $@jq-arguments < $file |
      slurp |
      to-lines > $file
}