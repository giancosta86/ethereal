use ./fs

pragma unknown-command = disallow

var configuration-path = ~/.curlrc

#
# Configures curl so that it only shows errors.
#
fn display-errors-only {
  echo '--silent --show-error' >> $configuration-path
}

#
# Runs a block where every `curl` invocation will show output only on failure.
#
fn with-silence { |block|
  fs:with-path-sandbox $configuration-path {
    display-errors-only

    $block
  }
}