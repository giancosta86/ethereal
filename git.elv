use os
use ./lang

pragma unknown-command = disallow

var git~ = (external git)

#
# Emits the current branch.
#
fn get-branch {
  git branch --show-current
}

#
# Switches to the requested branch, creating it if needed
#
fn ensure-in-branch { |@arguments|
  var branch = (lang:get-single-input $arguments)

  try {
    git switch $branch 2> $os:dev-null
  } catch {
    git switch -c $branch
  }
}