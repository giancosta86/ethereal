use file
use os
use path
use str
use ./lang
use ./map
use ./seq

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

fn save-anywhere { |path content|
  var parent = (path:dir $path)
  os:mkdir-all $parent

  print $content > $path
}

fn clean-dir { |directory|
  put $directory/*[nomatch-ok] | each { |entry|
    os:remove-all $entry
  }
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

fn equal-files { |left-path right-path|
  put ?(cmp -s $left-path $right-path) |
    eq (all) $ok
}

fn find-duplicates {
  each { |file-path|
    if (not (os:is-regular $file-path)) {
      continue
    }

    var file-size = (os:stat $file-path)[size]

    put [$file-size $file-path]
  } |
    map:multi-value |
    map:values |
    keep-if { |files-having-same-size|
      count $files-having-same-size |
        > (all) 1
    } |
    each { |files-having-same-size|
      all $files-having-same-size |
        seq:equivalence-classes &equality=$equal-files~ |
          keep-if { |equal-files| > (count $equal-files) 1 }
    }
}
