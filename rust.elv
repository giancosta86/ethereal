use ./-rust/rustdoc
use ./-rust/style
use ./-rust/tests

fn check { |&run-clippy=$true &check-rustdoc=$true|
  style:check &run-clippy=$run-clippy

  if $check-rustdoc {
    rustdoc:check
  }

  tests:run
}