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
# * `rev-parse --abbrev-ref HEAD`: returns the current reference from the previous `checkout` (or `clone`) operation
#
# * `pull`: if the `source-map` argument passed when creating the command was a function, calls it and retrieves the latest version of the source map, then updates the files in the target directory.
#
# The execution of both commands can be altered - just like Git - via the optional `-C <current directory>` flag.
#
# Please, note: SOURCE-URL and GIT-REFERENCE can actually be arbitrary strings, without the usual constraints.
#
fn create-command { |@arguments|
  var potential-source-map = (lang:get-single-input $arguments)

  var default-branch = main

  var context-by-dir = [&]

  fn get-context {
    if (not (has-key $context-by-dir $pwd)) {
      printf 'The directory "%s" was not cloned via this command instance!' $pwd |
        fail (all)
    }

    put $context-by-dir[$pwd]
  }

  fn set-context { |new-context|
    set context-by-dir = (assoc $context-by-dir $pwd $new-context)
  }

  fn update-repository-files {
    var context = (get-context)

    var repository-map = $context[repository-map]

    var reference = $context[reference]

    if (not (has-key $repository-map $reference)) {
      var source-url = $context[source-url]

      printf 'Missing reference "%s" in repository at source url "%s"' $reference $source-url |
        fail (all)
    }

    var reference-files = $repository-map[$reference]

    fs:clean-dir $pwd

    keys $reference-files | each { |entry-path|
      fs:save-all $entry-path $reference-files[$entry-path]
    }
  }

  fn clone { |@arguments|
    var source-url target-dir = (all $arguments[-2..])

    var source-map = (lang:resolve $potential-source-map)

    if (not (has-key $source-map $source-url)) {
      printf 'Missing source url "%s" in source map' $source-url |
        fail (all)
    }
    var repository-map = $source-map[$source-url]

    os:mkdir-all $target-dir
    tmp pwd = $target-dir

    set-context [
      &source-url=$source-url
      &reference=$default-branch
      &repository-map=$repository-map
    ]

    update-repository-files
  }

  fn checkout { |@arguments|
    var reference = $arguments[-1]

    var context = (get-context)

    var updated-context = (assoc $context reference $reference)

    set-context $updated-context

    update-repository-files
  }

  fn rev-parse { |@arguments|
    var allowed-arguments = [--abbrev-ref HEAD]

    if (not-eq $arguments $allowed-arguments) {
      printf 'Allowed argument list: %s' $allowed-arguments |
        fail (all)
    }

    var context = (get-context)

    put $context[reference]
  }

  fn pull {
    var context = (get-context)

    var source-url = $context[source-url]

    var updated-source-map = (lang:resolve $potential-source-map)

    var updated-repository-map = $updated-source-map[$source-url]

    var updated-context = (assoc $context repository-map $updated-repository-map)

    set-context $updated-context

    update-repository-files
  }

  var commands = [
    &clone=$clone~
    &checkout=$checkout~
    &rev-parse=$rev-parse~
    &pull=$pull~
  ]

  fn fake-git { |@git-arguments|
    flag:call { |&C=$pwd command @command-arguments|
      tmp pwd = $C

      if (not (has-key $commands $command)) {
        printf 'Unsupported "%s" command' $command |
          fail (all)
      }

      $commands[$command] $@command-arguments
    } $git-arguments
  }

  put $fake-git~
}