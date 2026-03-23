use ./fs
use ./lang

pragma unknown-command = disallow

var -pdfjam~ = (external pdfjam)

#
# Uses pdfjam to convert the given PDF documents to new documents having A5 format (and .a5.pdf extension) - applying the requested options.
#
fn to-a5 { |&scale=1.2 @arguments|
  lang:get-inputs $arguments | each { |source-path|
    fs:switch-ext $source-path '.a5.pdf' |
      -pdfjam --outfile (all) --a5paper --scale $scale $source-path
  }
}