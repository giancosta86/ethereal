use ./lang

pragma unknown-command = disallow

#
# Takes a block and redirects its out to stdout.
#
var out = { |block| $block }

#
# Takes a block and redirects its out to stderr.
#
var err = { |block| $block > &2 }

#
# Creates a writer that takes a block and appends its out to the given file (object or path).
#
fn to-file { |@arguments|
  var path = (lang:get-single-input $arguments)

  put { |block| $block >> $path }
}
