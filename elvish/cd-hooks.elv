use os
use path
use ../fs
use ../lang

#
# Given a map of params - via pipe or as argument - creates and registers a pair of "cd" hooks.
#
# The parameters are the following:
#
# * `before`: function running in the source directory and taking as argument the target directory;
#             if omitted, an empty implementation will be provided.
#
# * `after`: function running in the target directory and taking no inputs;
#            if omitted, an empty implementation will be provided.
#
# * `after-now`: if set to $true (the default), runs the actual `after` implementation right at the
#                end of the registration process.
#
# * debug-id: when set to a value, shows debug information before and after running each hook.
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
# * all the byte output is redirected to stderr, while the value output is filtered out.
#
# * if the target directory does not exist, the hooks won't be called.
#
# The function emits a token that can be passed to `unregister`.
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

  var before-block = (lang:get-value $params before)

  var after-block = (lang:get-value $params after)

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

        if (not (os:is-dir $target-dir)) {
          return
        }

        set status = $IN-BEFORE-HOOK

        try {
          log &emoji=🚪 Running BEFORE block from '"'$pwd'"' to '"'$target-dir'"'...

          if $before-block {
            $before-block $target-dir
          }
        } catch e {
          show $e
          set status = $OUT-OF-HOOKS-PAIR
        } else {
          set status = $BETWEEN-HOOKS
        } finally {
          log &emoji=🚪 Done BEFORE block from '"'$pwd'"' to '"'$target-dir'"'
        }
      } | only-bytes >&2
    }

    fn after-hook { |_|
      {
        if (not-eq $status $BETWEEN-HOOKS) {
          return
        }

        set status = $IN-AFTER-HOOK

        try {
          log &emoji=🪟 Running AFTER block for '"'$pwd'"'...

          if $after-block {
            $after-block
          }
        } catch e {
          show $e
        } finally {
          log &emoji=🪟 Done AFTER block for '"'$pwd'"'

          set status = $OUT-OF-HOOKS-PAIR
        }
      } | only-bytes >&2
    }

    set before-chdir = (conj $before-chdir $before-hook~)

    set after-chdir = (conj $after-chdir $after-hook~)

    put [
      &before-hook=$before-hook~
      &after-hook=$after-hook~
    ]
  }

  {
    var after-now = (lang:get-value &default=$true $params after-now)

    if (and $after-now $after-block) {
      $after-block |
        only-bytes >&2
    }
  }
}

#
# Given the token emitted by `register`, unregisters the related hooks.
#
fn unregister { |@arguments|
  var registration-token = (lang:get-single-input $arguments)

  set before-chdir = [(
    all $before-chdir |
      keep-if { |hook|
        not-eq $hook $registration-token[before-hook]
      }
  )]

  set after-chdir = [(
    all $after-chdir |
      keep-if { |hook|
        not-eq $hook $registration-token[after-hook]
      }
  )]
}

#
# Temporary removes all the chdir hooks, while executing the given block.
#
fn with-reset { |block|
  tmp before-chdir = []

  tmp after-chdir = []

  $block
}

#
# Takes in input - via pipe or as argument - the params map required by `register`,
# which can take a few additional keys:
#
# * `pre-register`: a function taking as arguments the <source> dir and the <target> dir,
#                   called right before registering the hooks. Any output is discarded.
#
# * `pre-unregister`: a function taking as arguments the <source> dir and the <target> dir,
#                     called right before unregistering the hooks. Any output is discarded.
#
# 1. Create a <source> temporary directory
#
# 2. Create a <target> temporary directory.
#
# 3. Temporarily reset all the chdir hooks.
#
# 4. Run <pre-register> - if declared - passing <source> and <target>.
#
# 5. Move into <source>.
#
# 6. Call `register` passing the given params - with `after-now` always set to $false.
#
# 7. Move into the <target> directory, thus triggering the hooks.
#
# 8. Run <pre-unregister> - if declared - passing <source> and <target>
#
# 9. Restore the previous hook state
#
# The function emits the outputs of its <pre-register> and <pre-unregister> functions, if defined.
#
# Please, note: do **NOT** run Velvet assertions within hooks; instead, set up callbacks to be called
# right after this function.
#
fn test { |@arguments|
  var params = (lang:get-single-input $arguments)

  fs:with-temp-dir { |source-dir|
    fs:with-temp-dir { |target-dir|
      with-reset {
        var pre-register = (lang:get-value $params pre-register)
        if $pre-register {
          $pre-register $source-dir $target-dir
        }

        cd $source-dir

        assoc $params after-now $false |
          register |
          only-bytes

        cd $target-dir

        var pre-unregister = (lang:get-value $params pre-unregister)
        if $pre-unregister {
          $pre-unregister $source-dir $target-dir
        }
      }
    }
  }
}