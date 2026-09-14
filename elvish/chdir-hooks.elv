use path
use ../fs
use ../lang

fn register { |@arguments|
  var params = (lang:get-single-input $arguments)

  var run-after = (lang:get-value &default=$true $params run-after)

  var log~ = (
    var debug-id = (lang:get-value $params debug-id)

    if $debug-id {
      put { |&emoji=⚡ @arguments|
        echo $emoji $debug-id': ' $@arguments
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

  var in-hooks = $false

  var latest-dir = $nil

  var in-after-hook = $false

  fn before-hook { |next-dir|
    if $in-hooks {
      return
    }

    set next-dir = (path:abs $next-dir)

    if (eq $next-dir $latest-dir) {
      return
    }

    if (eq $next-dir $pwd) {
      return
    }

    set in-hooks = $true
    set latest-dir = $next-dir

    try {
      log &emoji=🚪 Running BEFORE block for $next-dir... >&2

      $before-block $next-dir

      log &emoji=🚪 Done BEFORE block for $next-dir >&2
    } catch e {
      show $e
    }
  }

  fn after-hook { |_|
    if (not $in-hooks) {
      return
    }

    if (not-eq $pwd $latest-dir) {
      return
    }

    if $in-after-hook {
      return
    }

    set in-after-hook = $true

    try {
      log &emoji=🪟 Running AFTER block for $pwd... >&2

      $after-block

      log &emoji=🪟 Done AFTER block for $pwd >&2
    } catch e {
      show $e
    } finally {
      set in-after-hook = $false
      set in-hooks = $false
    }
  }

  set before-chdir = (conj $before-chdir $before-hook~)

  set after-chdir = (conj $after-chdir $after-hook~)

  if $run-after {
    $after-block
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