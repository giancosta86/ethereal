use ./-rust/rustdoc
use ./-rust/style
use ./-rust/tests

#
# Runs a series of Rust-related checks at the current directory:
#
# 1. Run `cargo fmt` to check the code style.
#
# 2. If `&run-clippy` is enabled, run `cargo clippy` an all targets and features, with warnings as errors.
#
# 3. If `&check-rustdoc` is enabled, run `cargo doc` on all features, with warnings as errors.
#
# 4. Run `cargo test` with no feature enabled.
#
# 5. Run `cargo test` with all features enabled.
#
fn check { |&run-clippy=$true &check-rustdoc=$true|
  style:check &run-clippy=$run-clippy

  if $check-rustdoc {
    rustdoc:check
  }

  tests:run
}