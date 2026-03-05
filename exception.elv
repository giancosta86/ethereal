use ./lang

pragma unknown-command = disallow

fn is-exception { |@arguments|
  deprecate 'Use lang:is-exception instead'
  lang:is-exception $@arguments
}

#
# If the input value is an exception and has the `reason` key, emits the related value - or $nil otherwise.
#
fn get-reason { |@arguments|
  var potential-exception = (lang:get-single-input $arguments)

  if (lang:is-exception $potential-exception) {
    lang:get-value $potential-exception reason
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

  and $reason (has-key $reason type) (eq $reason[type] fail) |
    bool (all)
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