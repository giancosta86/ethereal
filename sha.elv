use ./lang

pragma unknown-command = disallow

var -sha256sum~ = (external sha256sum)

#
# Computes the SHA256 hash for the given input value - using the external sha256sum command.
#
fn compute256 { |@arguments|
  lang:get-single-input $arguments |
    print (all) |
    -sha256sum |
    put (all)[..64]
}