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

#
# Takes in input a semantic version component ("major"|"minor"|"patch"),
# then performs the following steps to create a new version-based branch:
#
# 1. Switch to main
#
# 2. Try to pull the latest commits for main
#
# 3. Detect the version-based branch associated with the latest version:
#
#    * if no version-based branch exists, just create a 'v0.1.0' branch
#
#    * otherwise, apply `semver:bump`, also passing the requested component, then create a `v<new-version>` branch
#
# 4. Finally, switch to the newly-created branch.
#
fn bump-latest-version { |@arguments|
  var component = (lang:get-single-input $arguments)

  git checkout main

  try {
    git pull
  } catch {
    echo 💭 Could not pull the main branch... >&2
  }

  var latest-version = (get-latest-version)

  var new-version = (
    if $latest-version {
      semver:bump $latest-version $component
    } else {
      echo 💭 No existing version branches... >&2
      semver:parse 0.1
    }
  )

  var new-branch = 'v'(semver:to-string $new-version)

  git switch -c $new-branch
}