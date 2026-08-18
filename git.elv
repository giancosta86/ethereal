use os
use str
use ./lang
use ./semver

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

#
# Emits a semantic version object if the current branch name can be parsed - or $nil otherwise.
#
# Both an optional leading "v", as well as shortened versions (like «1.4»), are supported.
#
fn get-version {
  var branch = (get-branch)

  try {
    semver:parse $branch
  } catch {
    put $nil
  }
}

#
# Among all the branches whose name can be parsed as a semantic version,
# emits the biggest semantic version - or $nil if none could be found.
#
fn get-latest-version {
  git branch | each { |branch|
    try {
      str:trim-left $branch '* ' |
        semver:parse (all)
    } catch {
      put $nil
    }
  } |
    keep-if { |version| not-eq $version $nil } |
    order &less-than=$semver:less-than~ &reverse |
    lang:ensure-put |
    take 1
}
