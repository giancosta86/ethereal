use file
use os
use path
use str
use ./lang
use ./map
use ./seq

var -cp~ = (external cp)
var -mv~ = (external mv)

#
# Receives one or more paths in input - as arguments or via pipe - and removes the given leading dir path from each.
#
# The directory prefix can optionally end with `$path:separator` - in any case, it won't appear in the emitted paths.
#
fn relative-to { |directory-path @arguments|
  var simplified-directory-path = (
    str:trim-suffix $directory-path $path:separator
  )

  lang:get-inputs $arguments | each { |path|
    str:trim-prefix $path $simplified-directory-path''$path:separator
  }
}

#
# Takes a path - as argument or via pipe - and emits the core and the ext
# as subsequent values, where `ext` can be either a dotted extension or the empty string.
#
# In case of multiple extensions, only the last one is returned -
# in accordance with `path:ext`.
#
fn split-ext { |@arguments|
  var source-path = (lang:get-single-input $arguments)

  var ext = (path:ext $source-path)

  put (str:trim-suffix $source-path $ext) $ext
}

#
# Given a `source-path` and an `extension` (with or without leading dot) - passed as arguments or via pipe -
# emits a new path where the given `extension` replaces the extension in `source-path`.
#
fn switch-ext { |@arguments|
  var source-path new-ext = (lang:get-inputs $arguments)

  var core ext = (split-ext $source-path)

  put $core'.'(str:trim-prefix $new-ext .)
}

#
# Given a directory path as argument or via pipe, moves up via `cd..`
# until the current directory is not below such path.
#
fn ensure-not-in-directory { |@arguments|
  var directory-path = (lang:get-single-input $arguments)

  var abs-path = (path:abs $directory-path)

  while (str:has-prefix $pwd $abs-path) {
    cd ..
  }
}

#
# Returns the path of a created temp file - but without an associated open file structure.
#
fn temp-file-path { |&dir='' &pattern=$nil|
  var temp-file = (
    os:temp-file &dir=$dir (all (seq:value-as-list $pattern))
  )
  file:close $temp-file

  put $temp-file[name]
}

#
# Given a `path` and its `content` - passed as arguments or via pipe -
# creates all the intermediate directories so as to be able to save `content` into `path`.
#
fn save-anywhere { |@arguments|
  var path content = (lang:get-inputs $arguments)

  var parent = (path:dir $path)
  os:mkdir-all $parent

  print $content > $path
}

#
# If the given path exists, it must be a file; otherwise, it will be created.
#
fn ensure-file { |path|
  if (os:exists $path) {
    if (not (os:is-regular $path)) {
      fail 'Path "'$path'" exists, but it is not a file!'
    }
  } else {
    save-anywhere $path ''
  }
}

#
# Given a `directory` passed as argument or via pipe,
# removes all the files and subdirectories within it,
# leaving just the empty directory itself.
#
fn clean-dir { |@arguments|
  var directory = (lang:get-single-input $arguments)

  put $directory/*[nomatch-ok] | each { |entry|
    os:remove-all $entry
  }
}

#
# Given a consumer block taking a file path as argument,
# creates a temp file, passes its path to the block and, in the end,
# ensures it gets deleted.
#
# The block can be passed either as argument or via pipe.
#
fn with-temp-file { |&dir='' &pattern=$nil @arguments|
  var consumer = (lang:get-single-input $arguments)

  var temp-path = (temp-file-path &dir=$dir &pattern=$pattern)
  defer { os:remove-all $temp-path }

  $consumer $temp-path
}

#
# Given a consumer block taking a directory path as argument,
# creates a temp directory, passes its path to the block and, in the end,
# deletes its entire tree - after ensuring the pwd is out of it.
#
# The block can be passed either as argument or via pipe.
#
fn with-temp-dir { |&dir='' &pattern=$nil @arguments|
  var consumer = (lang:get-single-input $arguments)

  var temp-path = (os:temp-dir &dir=$dir (all (seq:value-as-list $pattern)))
  defer {
    ensure-not-in-directory $temp-path

    os:remove-all $temp-path
  }

  $consumer $temp-path
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
