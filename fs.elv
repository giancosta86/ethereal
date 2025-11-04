use file
use os
use path
use str
use ./lang
use ./map
use ./seq
use ./set

fn ensure-not-in-directory { |directory-path|
  var abs-path = (path:abs $directory-path)

  while (str:has-prefix $pwd $abs-path) {
    cd ..
  }
}

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
    $consumer $temp-path
  } finally {
    os:remove-all $temp-path
  }
}

fn with-temp-dir { |&dir='' &pattern=$nil consumer|
  var temp-path = (os:temp-dir &dir=$dir (all (seq:value-as-list $pattern)))

  try {
    $consumer $temp-path
  } finally {
    ensure-not-in-directory $temp-path

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

fn with-file-sandbox { |path block|
  if (os:is-dir $path) {
    fail 'The path must be a regular file!'
  }

  var backup-path

  if (os:is-regular $path) {
    set backup-path = (temp-file-path)

    copy $path $backup-path
  } else {
    set backup-path = $nil
  }

  try {
    $block
  } finally {
    os:remove-all $path

    if $backup-path {
      move $backup-path $path
    }
  }
}

fn with-dir-sandbox { |path block|
  var abs-path = (path:abs $path)

  if (os:is-regular $abs-path) {
    fail 'The path must be a directory!'
  }

  if (eq $abs-path /) {
    fail 'Cannot apply a sandbox to the file system root!'
  }

  var backup-path

  if (os:is-dir $abs-path) {
    set backup-path = (os:temp-dir)
    os:remove-all $backup-path

    copy $abs-path $backup-path
  } else {
    set backup-path = $nil
  }

  try {
    $block
  } finally {
    ensure-not-in-directory $abs-path

    os:remove-all $abs-path

    if $backup-path {
      move $backup-path $abs-path
    }
  }
}

fn switch-extension { |source-path new-extension|
  var current-extension = (path:ext $source-path)

  var path-without-extension = (
    if (not-eq $current-extension '') {
      put $source-path[..-(count $current-extension)]
    } else {
      put $source-path
    }
  )

  var dotted-new-extension = (
    if (str:has-prefix $new-extension '.') {
      put $new-extension
    } else {
      put '.'$new-extension
    }
  )

  put $path-without-extension''$dotted-new-extension
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