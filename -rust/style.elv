use ./tools

fn -check-format {
  echo 🎨 Checking source code format...
  tools:cargo fmt --check
  echo ✅ Source code format OK!
}

fn -run-clippy {
  echo 📎 Running clippy checks...
  tools:cargo clippy --all-targets --all-features -- -D warnings
  echo ✅ Clippy checks OK!
}

fn check { |&run-clippy=$true|
  -check-format

  if $run-clippy {
    -run-clippy
  }
}
