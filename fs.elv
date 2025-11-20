use file
use os
use path
use str
use ./lang
use ./map
use ./seq

var -cp~ = (external cp)
var -mv~ = (external mv)

fn split-ext { |@arguments|
  var source-path = (lang:get-single-input $arguments)

  var ext = (path:ext $source-path)

  var core = (
    if (not-eq $ext '') {
      put $source-path[..-(count $ext)]
    } else {
      put $source-path
    }
  )

  put $core $ext
}

fn switch-ext { |@arguments|
  var source-path new-ext = (lang:get-inputs $arguments)

  var core ext = (split-ext $source-path)

  var dotted-new-ext = (
    if (str:has-prefix $new-ext '.') {
      put $new-ext
    } else {
      put '.'$new-ext
    }
  )

  put $core''$dotted-new-ext
}

fn ensure-not-in-directory { |@arguments|
  var directory-path = (lang:get-single-input $arguments)

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

fn save-anywhere { |@arguments|
  var path content = (lang:get-inputs $arguments)

  var parent = (path:dir $path)
  os:mkdir-all $parent

  print $content > $path
}

fn clean-dir { |@arguments|
  var directory = (lang:get-single-input $arguments)

  put $directory/*[nomatch-ok] | each { |entry|
    os:remove-all $entry
  }
}

fn with-temp-file { |&dir='' &pattern=$nil @arguments|
  var consumer = (lang:get-single-input $arguments)

  var temp-path = (temp-file-path &dir=$dir &pattern=$pattern)

  try {
    $consumer $temp-path
  } finally {
    os:remove-all $temp-path
  }
}

fn with-temp-dir { |&dir='' &pattern=$nil @arguments|
  var consumer = (lang:get-single-input $arguments)

  var temp-path = (os:temp-dir &dir=$dir (all (seq:value-as-list $pattern)))

  try {
    $consumer $temp-path
  } finally {
    ensure-not-in-directory $temp-path

    os:remove-all $temp-path
  }
}

fn touch { |@arguments|
  var path = (lang:get-single-input $arguments)

  print > $path
}

fn copy { |@arguments|
  var from to = (lang:get-inputs $arguments)

  -cp -r $from $to
}

fn move { |@arguments|
  var from to = (lang:get-inputs $arguments)

  -mv $from $to
}

fn mkcd { |&perm=0o755 @arguments|
  var @components = (lang:get-inputs $arguments)

  var actual-path = (path:join $@components)

  os:mkdir-all &perm=$perm $actual-path

  cd $actual-path
}

fn with-file-sandbox { |@arguments|
  var path block = (lang:get-inputs $arguments)

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

fn with-dir-sandbox { |@arguments|
  var path block = (lang:get-inputs $arguments)

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

fn equal-files { |@arguments|
  var left-path right-path = (lang:get-inputs $arguments)

  put ?(cmp -s $left-path $right-path) |
    eq (all) $ok
}

fn find-duplicates { |@arguments|
  lang:get-inputs $arguments |
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
