use path
use ../fs
use ../lang

#
# Given a map of params - via pipe or as argument - creates and registers a pair of "cd" hooks.
#
# The parameters are the following:
#
# * `before`: function running in the source directory and taking as argument the target directory;
#             if omitted, an empty implementation will be provided
#
# * `after`: function running in the target directory and taking no inputs;
#            if omitted, an empty implementation will be provided
#
# * `run-after`: if set to $true (the default), runs the actual `after` implementation right at the
#                end of the registration process
#
# * debug-id: when set to a value, shows debug information before and after running each hook
#
#
# As for the hooks, the following properties are guaranteed:
#
# * non-rentrance - they won't be triggered by any "cd" called by their implementation blocks;
#
# * exception safety - exceptions will be automatically caught and displayed;
#
# * the AFTER hook only runs if the BEFORE hook completed successfully;
#
# * when moving to the current directory, they won't be triggered again;
#
# * all the output is redirected to stderr.
#
#
fn register { |@arguments|
  var params = (lang:get-single-input $arguments)

  var log~ = (
    var debug-id = (lang:get-value $params debug-id)

    if $debug-id {
      put { |&emoji=⚡ @arguments|
        echo $emoji $debug-id':' $@arguments
      }
    } else {
      put { |&emoji=$nil @arguments|
        #Just do nothing
      }
    }
  )

  var before-block = (
    lang:get-value $params before |
      coalesce (all) { |target-dir| }
  )

  var after-block = (
    lang:get-value $params after |
      coalesce (all) { }
  )

  {
    var OUT-OF-HOOKS-PAIR = out-of-hooks-pair

    var IN-BEFORE-HOOK = in-before-hook

    var BETWEEN-HOOKS = between-hooks

    var IN-AFTER-HOOK = in-after-hook

    var status = $OUT-OF-HOOKS-PAIR

    fn before-hook { |target-dir|
      {
        if (not-eq $status $OUT-OF-HOOKS-PAIR) {
          return
        }

        set target-dir = (path:abs $target-dir)

        if (eq $target-dir $pwd) {
          return
        }

        set status = $IN-BEFORE-HOOK

        try {
          log &emoji=🚪 Running BEFORE block from '"'$pwd'"' to '"'$target-dir'"'...

          $before-block $target-dir
        } catch e {
          show $e
          set status = $OUT-OF-HOOKS-PAIR
        } else {
          set status = $BETWEEN-HOOKS
        } finally {
          log &emoji=🚪 Done BEFORE block from '"'$pwd'"' to '"'$target-dir'"'
        }
      } >&2
    }

    fn after-hook { |_|
      {
        if (not-eq $status $BETWEEN-HOOKS) {
          return
        }

        set status = $IN-AFTER-HOOK

        try {
          log &emoji=🪟 Running AFTER block for '"'$pwd'"'...

          $after-block
        } catch e {
          show $e
        } finally {
          log &emoji=🪟 Done AFTER block for '"'$pwd'"'

          set status = $OUT-OF-HOOKS-PAIR
        }
      } >&2
    }

    set before-chdir = (conj $before-chdir $before-hook~)

    set after-chdir = (conj $after-chdir $after-hook~)
  }

  {
    var run-after = (lang:get-value &default=$true $params run-after)

    if $run-after {
      $after-block
    }
  }
}

#
# Temporary removes all the chdir hooks, while executing the given block.
#
fn with-temp-reset { |block|
  tmp before-chdir = []

  tmp after-chdir = []

  $block
}

#
# Takes in input - via pipe or as first argument - the params map required by `register` -
# and an init block as its (last) argument, then applies the following algorithm:
#
# 1. Temporarily reset all the chdir hooks.
#
# 2. Create a <source> temporary directory
#
# 3. Create a <target> temporary directory.
#
# 4. Run the init block, passing <source> and <target>.
#
# 5. Move into <source>.
#
# 6. Call `register` passing the given params - with `run-after` always set to $false.
#
# 7. Move into the <target> directory, thus triggering the hooks.
#
# Please, note: do **NOT** run Velvet assertions within hooks; instead, set up callbacks to be called
# right after this function.
#
fn test { |@arguments|
  var params init-block = (lang:get-mixed-inputs &min-values=2 &max-values=2 &min-args=1 $arguments)

  fs:with-temp-dir { |source-dir|
    fs:with-temp-dir { |target-dir|
      with-temp-reset {
        $init-block $source-dir $target-dir

        cd $source-dir

        assoc $params run-after $false |
          register

        cd $target-dir
      }
    }
  }
}