use str
use ./function

fn compute256 { |@arguments|
  var value = (function:get-single-input $@arguments)

  print $value |
    sha256sum |
    str:split ' ' (all) |
    take 1
}