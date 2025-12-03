use flag
use os
use path
use ./fs
use ./lang

pragma unknown-command = disallow

#
# Takes as input a SOURCE-URL => REPOSITORY-MAP map,
# where REPOSITORY-MAP is a GIT-REFERENCE => FILE-MAP map containing at least a `main` key,
# where, in turn, FILE-MAP is a RELATIVE-PATH => FILE-CONTENT map;
# the result is a command - another function - supporting a tiny subset of Git's functionality.
#
# In other words, `source-map` is a map potentially describing multiple branches/tags/...
# within multiple repositories at multiple urls;
# as a plus, it can be a function, that will be evaluated every time a related command is performed.
#
# In particular, the supported commands are:
#
# * `clone <SOURCE-URL> <DIRECTORY>`: creates `DIRECTORY` if missing, then performs a checkout of the `main` reference
#   for the given `SOURCE-URL`
#
# * `checkout <REFERENCE>`: deletes the content of the $pwd - which must have been cloned via the same command instance -
#    and creates the directory structure described by `REFERENCE` for the related `SOURCE-URL`
#
# The execution of both commands can be altered - just like Git - via the optional `-C <current directory>` flag.
#
# Please, note: SOURCE-URL and GIT-REFERENCE can actually be arbitrary strings, without the usual constraints.
#
fn create-command { |@arguments|
  var potential-source-map = (lang:get-single-input $arguments)

  var source-urls-by-dest = [&]

  fn checkout { |reference|
    if (not (has-key $source-urls-by-dest $pwd)) {
      printf 'Fake Git: the directory "%s" was not cloned via this command instance!' $pwd |
        fail (all)
    }

    var source-url = $source-urls-by-dest[$pwd]

    var source-map = (lang:resolve $potential-source-map)

    var repository-map = $source-map[$source-url]

    if (not (has-key $repository-map $reference)) {
      printf 'Fake Git: missing reference "%s" in repository at source url "%s"' $reference $source-url |
        fail (all)
    }

    fs:clean-dir $pwd

    var reference-files = $repository-map[$reference]

    keys $reference-files | each { |entry-path|
      fs:save-all $entry-path $reference-files[$entry-path]
    }
  }

  fn clone { |source-url dest|
    var source-map = (lang:resolve $potential-source-map)

    if (not (has-key $source-map $source-url)) {
      printf 'Fake Git: missing source url "%s" in source map' $source-url |
        fail (all)
    }

    set source-urls-by-dest = (
      assoc $source-urls-by-dest (path:abs $dest) $source-url
    )

    os:mkdir-all $dest

    tmp pwd = $dest

    checkout main
  }

  var commands = [
    &clone=$clone~
    &checkout=$checkout~
  ]

  fn fake-git { |@git-arguments|
    flag:call { |&C=$pwd command @command-arguments|
      tmp pwd = $C

      if (not (has-key $commands $command)) {
        printf 'Fake Git: unsupported "%s" command' $command |
          fail (all)
      }

      $commands[$command] $@command-arguments
    } $git-arguments
  }

  put $fake-git~
}