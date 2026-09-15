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
      coalesce (all) { |next-dir| }
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

    fn before-hook { |next-dir|
      if (not-eq $status $OUT-OF-HOOKS-PAIR) {
        return
      }

      set next-dir = (path:abs $next-dir)

      if (eq $next-dir $pwd) {
        return
      }

      set status = $IN-BEFORE-HOOK

      try {
        log &emoji=🚪 Running BEFORE block from '"'$pwd'"' to '"'$next-dir'"'... >&2

        $before-block $next-dir
      } catch e {
        show $e
        set status = $OUT-OF-HOOKS-PAIR
      } else {
        set status = $BETWEEN-HOOKS
      } finally {
        log &emoji=🚪 Done BEFORE block from '"'$pwd'"' to '"'$next-dir'"' >&2
      }
    }

    fn after-hook { |_|
      if (not-eq $status $BETWEEN-HOOKS) {
        return
      }

      set status = $IN-AFTER-HOOK

      try {
        log &emoji=🪟 Running AFTER block for '"'$pwd'"'... >&2

        $after-block
      } catch e {
        show $e
      } finally {
        log &emoji=🪟 Done AFTER block for '"'$pwd'"' >&2

        set status = $OUT-OF-HOOKS-PAIR
      }
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

fn with-temp-reset { |block|
  tmp before-chdir = []

  tmp after-chdir = []

  $block
}

fn test { |@arguments|
  with-temp-reset {
    var params init-block = (lang:get-mixed-inputs &min-values=2 &max-values=2 &min-args=1 $arguments)

    fs:with-temp-dir { |source-dir|
      cd $source-dir

      fs:with-temp-dir { |target-dir|
        $init-block $source-dir $target-dir

        assoc $params run-after $false |
          register

        cd $target-dir
      }
    }
  }
}