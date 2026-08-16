use ./tools

fn -run-vanilla-tests {
  echo 🔬 Running tests with no features enabled...
  tools:cargo test
  echo ✅ Tests with no features OK!
}

fn -run-tests-with-all-features {
  echo 🔬 Running tests with all the features enabled...
  tools:cargo test --all-features
  echo ✅ Tests with all the features OK!
}

fn run {
  -run-vanilla-tests

  -run-tests-with-all-features
}