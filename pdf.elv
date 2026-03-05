use ./fs
use ./lang

var -pdfjam~ = (external pdfjam)

#
# Uses pdfjam to convert the given documents to PDF, applying the requested options.
#
fn to-a5 { |&scale=1.2 @arguments|
  lang:get-inputs $arguments | each { |source-path|
    fs:switch-ext $source-path '.a5.pdf' |
      -pdfjam --outfile (all) --a5paper --scale $scale $source-path
  }
}