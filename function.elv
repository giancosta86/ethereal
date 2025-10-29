fn get-single-input { |@arguments|
  var arg-count = (count $arguments)

  if (== $arg-count 0) {
    one
  } elif (== $arg-count 1) {
    put $arguments[0]
  } else {
    fail 'Arity mismatch! At most 1 argument expected!'
  }
}

fn get-input-flow { |@arguments|
  var arg-count = (count $arguments)

  all

  if (> $arg-count 0) {
    all $arguments
  }
}