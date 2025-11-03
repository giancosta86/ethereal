use file
use os
use path
use str
use ./hash-set
use ./lang
use ./map
use ./seq

fn temp-file-path { |&dir='' &pattern=$nil|
  var temp-file = (
    os:temp-file &dir=$dir (all (seq:value-as-list $pattern))
  )
  file:close $temp-file

  put $temp-file[name]
}

fn with-temp-file { |&dir='' &pattern=$nil consumer|
  var temp-path = (temp-file-path &dir=$dir &pattern=$pattern)

  try {
    $consumer $temp-path |
      lang:no-output
  } finally {
    os:remove-all $temp-path
  }
}

fn with-temp-dir { |&dir='' &pattern=$nil consumer|
  var temp-path = (os:temp-dir &dir=$dir (all (seq:value-as-list $pattern)))

  try {
    $consumer $temp-path |
      lang:no-output
  } finally {
    set pwd = (path:dir $temp-path)
    os:remove-all $temp-path
  }
}

fn touch { |path|
  print > $path
}

fn copy { |from to|
  cp -r $from $to
}

fn move { |from to|
  mv $from $to
}

fn mkcd { |&perm=0o755 @components|
  var actual-path = (path:join $@components)

  os:mkdir-all &perm=$perm $actual-path

  cd $actual-path
}

fn -with-path-sandbox { |inputs|
  var path = (path:abs $inputs[path])
  var backup-suffix = $inputs[backup-suffix]
  var test-path-is-ok = $inputs[test-path-is-ok]
  var test-path-is-wrong = $inputs[test-path-is-wrong]
  var error-message = $inputs[error-message]
  var block = $inputs[block]

  var backup-path

  if ($test-path-is-ok $path) {
    set backup-path = $path''$backup-suffix

    copy $path $backup-path
  } elif ($test-path-is-wrong $path) {
    fail $error-message
  } else {
    set backup-path = $nil
  }

  try {
    $block |
      lang:no-output
  } finally {
    var parent-dir = (path:dir $path)

    set pwd = (lang:ternary (os:is-dir $parent-dir) $parent-dir $pwd)

    os:remove-all $path

    if $backup-path {
      move $backup-path $path
    }
  }
}

fn with-file-sandbox { |&backup-suffix='.orig' path block|
  -with-path-sandbox [
    &path=$path
    &backup-suffix=$backup-suffix
    &test-path-is-ok=$os:is-regular~
    &test-path-is-wrong=$os:is-dir~
    &error-message='The path must be a regular file!'
    &block=$block
  ]
}

fn with-dir-sandbox { |&backup-suffix='.orig' path block|
  -with-path-sandbox [
    &path=$path
    &backup-suffix=$backup-suffix
    &test-path-is-ok=$os:is-dir~
    &test-path-is-wrong=$os:is-regular~
    &error-message='The path must be a directory!'
    &block=$block
  ]
}

#TODO! Test this!
fn potential-ext { |source-path new-ext|
  var ext = (path:ext $source-path)

  var path-without-ext = $source-path[..-(count $ext)]

  var extension-dot = (lang:ternary (str:has-prefix $new-ext '.') '' '.')

  put $path-without-ext''$extension-dot''$new-ext
}

#TODO! Test this!
fn find-duplicates {
  var files-by-size = [&]

  put **[type:regular] | each { |file|
    var file-size = (os:stat $file)[size]

    var files-of-given-size = (map:get-value $files-by-size $file-size &default=[])

    set files-by-size = (
      assoc $files-by-size $file-size [$@files-of-given-size $file]
    )
  }

  set files-by-size = (map:filter $files-by-size { |size files-of-this-size|
    > (count $files-of-this-size) 1
  })

  put $files-by-size
}