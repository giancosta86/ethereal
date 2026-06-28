use ./git

fn within-temp-repo { |repo-consumer|
  fs:with-temp-dir { |temp-dir|
    cd $temp-dir

    git init --initial-branch=main

    git config --local user.name "Test User"
    git config --local user.email "test@gianlucacosta.info"

    git switch -c main
    echo Hello > test.txt
    git add .
    git commit -m "First commit"

    $repo-consumer $temp-dir
  }
}

>> 'In git module' {
  >> 'getting the current branch' {
    within-temp-repo { |temp-repo|
      git switch -c dodo

      git:get-branch |
        should-be dodo
    }
  }

  >> 'ensuring to be in a branch' {
    >> 'when the branch does not exist' {
      within-temp-repo { |temp-repo|
        git:ensure-in-branch dodo

        git:get-branch |
          should-be dodo
      }
    }

    >> 'when the branch exists' {
      within-temp-repo { |temp-repo|
        git switch -c dodo

        git switch main

        put dodo |
          git:ensure-in-branch

        git:get-branch |
          should-be dodo
      }
    }
  }
}