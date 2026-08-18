use ./git

pragma unknown-command = disallow

var git~ = (external git)
var gh~ = (external gh)

#
# Opens the browser to create a pull request for the current branch.
#
fn new-pr {
  git push origin (git:get-branch)

  gh pr create --web
}

#
# Returns the unsorted list of the names of the repositories owned by the current `gh` user.
#
fn get-repos { |&limit=1000|
  gh repo list --source --limit $limit --json name --jq '.[].name'
}