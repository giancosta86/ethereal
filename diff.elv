use ./fs

#TODO! Test this!

fn diff { |&throw=$false left right|
  var left-path = (fs:temp-file-path)
  var right-path = (fs:temp-file-path)

  print $left > $left-path
  print $right > $right-path

  var exception = $nil

  try {
    (external diff) --color=always -u $left-path $right-path
  } catch e {
    set exception = $e
  } finally {
    fs:rimraf $left-path
    fs:rimraf $right-path
  }

  if (and $exception $throw) {
    fail $e
  }
}