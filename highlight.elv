use ./fs

pragma unknown-command = disallow

var -pygmentize = (fs:get-external pygmentize)

#
# If pygmentize is available, performs syntax highlighting in the requested `format`
# on the source code passed via pipe; otherwise, just re-emits the lines unaltered.
#
fn stream { |format|
  if $-pygmentize {
    $-pygmentize -l $format
  } else {
    only-bytes
  }
}

#
# If pygmentize is available, performs syntax highlighting in the requested `format`
# on the source code contained in `path`; otherwise, just re-emits the lines unaltered.
#
fn file { |path format|
  to-lines < $path |
    stream $format
}