use ./git
use ./semver

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

  >> 'getting the head' {
    >> 'when on a branch' {
      within-temp-repo { |temp-repo|
        var initial-commit = (git rev-parse main)

        git:get-head |
          should-be $initial-commit
      }
    }

    >> 'when at a specific commit' {
      within-temp-repo { |temp-repo|
        var initial-commit = (git rev-parse main)

        echo World > beta.txt
        git add .
        git commit -m 'Second commit'

        git checkout $initial-commit

        git:get-head |
          should-be $initial-commit
      }
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

  >> 'getting the branch version' {
    >> 'when not convertible' {
      within-temp-repo { |temp-repo|
        git switch -c dodo

        git:get-version |
          should-be $nil
      }
    }

    >> 'when convertible' {
      fn assert-branch-version { |version-string|
        within-temp-repo { |temp-repo|
          git switch -c $version-string

          git:get-version |
            should-be (semver:parse $version-string)
        }
      }

      >> 'with leading v' {
        assert-branch-version v1.2.3-my-test-pre+my-test-build
      }

      >> 'without leading v' {
        assert-branch-version 4.5.6
      }

      >> 'when shortened' {
        assert-branch-version v7.8
      }
    }
  }

  >> 'getting the latest version' {
    fn assert-latest-version { |branches latest-version-source|
      var latest-version = (
        lang:map $latest-version-source $semver:parse~
      )

      within-temp-repo { |temp-repo|
        all $branches | each { |branch|
          git switch -c $branch
        }

        git switch main

        git:get-latest-version |
          should-be $latest-version
      }
    }

    >> 'when the repository only has the main branch' {
      assert-latest-version [] $nil
    }

    >> 'when the repository has no parsable branches' {
      assert-latest-version [alpha beta gamma] $nil
    }

    >> 'when the repository has one parsable branch' {
      assert-latest-version [alpha v1.7 dodo] v1.7
    }

    >> 'when the repository has multiple parsable branches' {
      assert-latest-version [
        v1.7
        v1.7.1
        v2.5
        v3.6.5
        v0.4
        v2.9.11
      ] v3.6.5
    }
  }

  >> 'bumping the latest version' {
    fn assert-bumping-branch { |branches component new-branch|
      within-temp-repo { |temp-repo|
        all $branches | each { |branch|
          git switch -c $branch
        }

        git:bump-latest-version $component

        git:get-branch |
          should-be $new-branch
      }
    }

    >> 'when the repository only has the main branch' {
      assert-bumping-branch [] major v0.1.0
    }

    >> 'when the repository has multiple versions' {
      >> 'when bumping the major component' {
        assert-bumping-branch [
          v2.3
          dodo
          v5.6.2
          v1.7.4
          v3.2
          v7.8.9
          v5.6.0
        ] major v8.0.0
      }

      >> 'when bumping the minor component' {
        assert-bumping-branch [
          v2.3
          dodo
          v5.6.2
          v1.7.4
          v3.2
          v7.8.9
          v5.6.0
        ] minor v7.9.0
      }

      >> 'when bumping the patch component' {
        assert-bumping-branch [
          v2.3
          dodo
          v5.6.2
          v1.7.4
          v3.2
          v7.8.9
          v5.6.0
        ] patch v7.8.10
      }
    }
  }
}