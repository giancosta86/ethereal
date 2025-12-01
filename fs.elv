use file
use os
use path
use str
use ./lang
use ./map
use ./seq

pragma unknown-command = disallow

var -cp~ = (external cp)
var -mv~ = (external mv)
var -cmp~ = (external cmp)

#
# Receives one or more paths in input - as arguments or via pipe - and removes the given leading dir path from each.
#
# The directory prefix can optionally end with `$path:separator` - in any case, it won't appear in the emitted paths.
#
fn relative-to { |dir-path @arguments|
  var simplified-dir-path = (
    str:trim-suffix $dir-path $path:separator
  )

  lang:get-inputs $arguments | each { |path|
    str:trim-prefix $path $simplified-dir-path''$path:separator
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
fn ensure-not-in-dir { |@arguments|
  var dir-path = (lang:get-single-input $arguments)

  var abs-path = (path:abs $dir-path)

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
# Given a `path`, passed as argument, and its `content` - passed as arguments or via pipe -
# creates all the intermediate directories so as to be able to save `content` into `path`.
#
fn save-anywhere { |path @arguments|
  var content = (lang:get-single-input $arguments)

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
  var dir = (lang:get-single-input $arguments)

  put $dir/*[nomatch-ok] | each { |entry|
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
    ensure-not-in-dir $temp-path

    os:remove-all $temp-path
  }

  $consumer $temp-path
}

#
# Copies `from` to `to` - where both are received either as arguments or via pipe.
#
# The source can be either a file or a directory.
#
fn copy { |@arguments|
  var from to = (lang:get-inputs $arguments)

  -cp -r $from $to
}

#
# Moves `from` to `to` - where both are received either as arguments or via pipe.
#
# The source can be either a file or a directory.
#
fn move { |@arguments|
  var from to = (lang:get-inputs $arguments)

  -mv $from $to
}

#
# Ensures a directory exists with all its parents, then cd's into it.
#
# The path components can be passed either as arguments or via pipe.
#
fn mkcd { |&perm=0o755 @arguments|
  var components = [(lang:get-inputs $arguments)]

  var actual-path = (path:join $@components)

  os:mkdir-all &perm=$perm $actual-path

  cd $actual-path
}

#
# Given a (potentially non-existent) file path and a block - both passed either as arguments or via pipe -
# ensures that, after the execution of the block, the file is restored to its original state.
#
# In particular, if the file did not exist at the beginning of the block,
# it will be deleted thereafter.
#
fn with-file-sandbox { |@arguments|
  var path block = (lang:get-inputs $arguments)

  var backup-path = (
    if (os:exists $path) {
      if (os:is-regular $path) {
        temp-file-path
      } else {
        fail 'Path "'$path'" exists and is not a regular file!'
      }
    } else {
      put $nil
    }
  )

  if $backup-path {
    copy $path $backup-path
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

#
# Given a (potentially non-existent) directory path and a block - both passed either as arguments or via pipe -
# ensures that, after the execution of the block, the entire directory tree is restored to its original state.
#
# In particular, if the directory did not exist at the beginning of the block,
# its tree will be deleted thereafter.
#
fn with-dir-sandbox { |@arguments|
  var path block = (lang:get-inputs $arguments)

  var backup-path = (
    if (os:exists $path) {
      if (os:is-dir $path) {
        os:temp-dir
      } else {
        fail 'Path "'$path'" exists and is not a directory!'
      }
    } else {
      put $nil
    }
  )

  var abs-path = (path:abs $path)

  if (eq $abs-path /) {
    fail 'Cannot apply a sandbox to the file system root!'
  }

  if $backup-path {
    os:remove-all $backup-path

    copy $path $backup-path
  }

  try {
    $block
  } finally {
    ensure-not-in-dir $path

    os:remove-all $abs-path

    if $backup-path {
      move $backup-path $abs-path
    }
  }
}

#
# Given two file paths - passed as arguments or via pipe -
# emits $true if they are equal in binary terms, according to the `cmp` command.
#
fn equal-files { |@arguments|
  var left-path right-path = (lang:get-inputs $arguments)

  put ?(-cmp --silent $left-path $right-path) |
    eq (all) $ok
}

#
# Given paths - passed as arguments or via pipe - ignores directories
# and emits lists, where each list contains at least two file paths
# having the very same content.
#
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
