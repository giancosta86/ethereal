use str
use ./lang

fn compute256 { |@arguments|
  lang:get-single-input $arguments |
    print (all) |
    sha256sum |
    str:split ' ' (all) |
    take 1
}