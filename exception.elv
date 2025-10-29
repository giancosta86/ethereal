use ./function

fn is-exception { |value|
  kind-of $value |
    eq (all) exception
}

fn get-reason { |@arguments|
  var potential-exception = (function:get-single-input $@arguments)

  if (
    and (is-exception $potential-exception) (has-key $potential-exception reason)
  ) {
    put $potential-exception[reason]
  } else {
    put $nil
  }
}

fn get-fail-content { |@arguments|
  var reason = (get-reason $@arguments)

  if (
    and $reason (has-key $reason content)
  ) {
    put $reason[content]
  } else {
    put $nil
  }
}

fn is-fail { |potential-exception|
  get-fail-content $potential-exception |
    not-eq (all) $nil
}

fn is-return { |@arguments|
  var reason = (get-reason $@arguments)

  if (
    and $reason (has-key $reason type) (has-key $reason name) |
      not (all)
  ) {
    put $false
    return
  }

  and (eq $reason[type] flow) (eq $reason[name] return)
}