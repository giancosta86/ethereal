#
# Displays, on multiple lines:
#
# 1. The given emoji and the description (followed by ':')
#
# 2. All the output of the given block
#
# 3. Three trailing instances of the emoji
#
fn section { |&emoji=🔎 description block|
  echo $emoji $description':'

  $block

  echo (repeat 3 $emoji)
}

#
# Prints out the given emoji and description (followed by ': '),
# then a user-friendly representation of the given value.
#
fn inspect { |&emoji=🔎 description value|
  var value-kind = (kind-of $value)

  if (eq $value-kind string) {
    echo $emoji $description": '"$value"'"
  } elif (has-value [list map] $value-kind) {
    echo $emoji $description':'
    pprint $value
  } elif (eq $value-kind exception) {
    echo $emoji $description':'
    show $value
  } else {
    echo $emoji $description": "(to-string $value)
  }
}