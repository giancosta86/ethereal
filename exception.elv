use ./lang

pragma unknown-command = disallow

#
# Emits $true if the input value is an exception, $false otherwise.
#
fn is-exception { |@arguments|
  lang:get-single-input $arguments |
    kind-of (all) |
    eq (all) exception
}

#
# If the input value is an exception and has the `reason` key, emits the related value - or $nil otherwise.
#
fn get-reason { |@arguments|
  var potential-exception = (lang:get-single-input $arguments)

  if (
    and (is-exception $potential-exception) (has-key $potential-exception reason)
  ) {
    put $potential-exception[reason]
  } else {
    put $nil
  }
}

#
# Emits $true if the input value is an exception induced by `fail` - or $false otherwise.
#
fn is-fail { |@arguments|
  var reason = (
    lang:get-single-input $arguments |
      get-reason (all)
  )

  and (not-eq $reason $nil) (has-key $reason type) (eq $reason[type] fail)
}

#
# If the input value is a `fail`-induced exception, emits its content - or $nil otherwise.
#
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

#
# Emits $true if the single input is an exception induced by `return` - or $false otherwise.
#
fn is-return { |@arguments|
  var reason = (get-reason $@arguments)

  and $reason (has-key $reason type) (eq $reason[type] flow) (has-key $reason name) (eq $reason[name] return) |
    bool (all)
}