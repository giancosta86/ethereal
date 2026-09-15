use os
use path
use re
use str
use ../lang
use ../map

pragma unknown-command = disallow

var sdkman-home = (path:join ~ .sdkman)

var init-script = (path:join $sdkman-home bin sdkman-init.sh)

var sdk-file = .sdkmanrc

#
# Emits the absolute path of the directory containing the requested SDK:
#
# * if the &version flag is passed, the directory will be the one of that specific version;
#
# * otherwise, the root directory for the candidate will be emitted.
#
# The directory might well not exist - this is just a path manipulation function.
#
fn get-candidate-dir { |candidate &version=$nil|
  var candidate-home = (
    path:join $sdkman-home candidates $candidate
  )

  if $version {
    path:join $candidate-home $version
  } else {
    put $candidate-home
  }
}

#
# Iterates over the candidates in the "candidates" directory,
# passing each candidate name to the given block.
#
fn each-candidate { |candidate-consumer|
  put $sdkman-home/candidates/*[type:dir][nomatch-ok] |
    each $path:base~ |
    each $candidate-consumer
}

#
# Given a candidate, returns the name of the related *_HOME environment variable.
#
fn get-candidate-home-var { |candidate|
  put (str:to-upper $candidate)'_HOME'
}

#
# Given a path, emits the most suitable value for a *_HOME variable:
#
# * if the source path is a "bin" directory, emits its parent
#
# * otherwise, emits the directory itself
#
fn -get-home-path { |@arguments|
  var path = (lang:get-single-input $arguments)

  if (eq (path:base $path) bin) {
    path:dir $path
  } else {
    put $path
  }
}

#
# Given a candidate, sets its *_HOME variable to the related PATH entry;
# if the given candidate has no PATH entries, the related *_HOME variable is unset.
#
fn -setup-candidate-home { |candidate|
  var home-var = (get-candidate-home-var $candidate)

  var candidate-root = (get-candidate-dir $candidate)

  all $paths | each { |path|
    if (str:has-prefix $path $candidate-root) {
      -get-home-path $path |
        set-env $home-var (all)

      return
    }
  }

  unset-env $home-var
}

#
# Defines a *_HOME variable for each SDK candidate found in PATH.
#
# If a candidate has no related PATH entry, its *_HOME is unset.
#
fn setup-sdk-homes {
  each-candidate $-setup-candidate-home~
}

#
# Reads the SDK file from the current directory and outputs
# a map whose keys are the requested candidates and the values are their related versions.
#
# If there is no SDK file, just emits an empty map.
#
fn get-sdkfile-candidates {
  if (not (os:is-regular $sdk-file)) {
    put [&]
    return
  }

  from-lines < $sdk-file |
    each { |line|
      var sdk-line-regex = '\s*(\S+)\s*=\s*(\S+)\s*'

      re:find $sdk-line-regex $line | each { |matcher|
        var candidate = $matcher[groups][1][text]
        var version = $matcher[groups][2][text]

        put [$candidate $version]
      }
    } |
        make-map
}

#
# First removes from PATH every reference to SDKMAN candidates;
# then, for each candidate found, prepends to PATH:
#
# * the "current/bin" file system object, if existing
#
# * the "current" file system object, if existing.
#
# The "overriding-versions" flag takes in input a <candidate><version> map - whose versions
# will replace the default, "current"-based paths.
#
# Anyway, if no directory can be found for the requested version of a candidate,
# such candidate won't be added to PATH.
#
fn -get-reset { |&overriding-versions=[&]|
  var current-based-map = (
    each-candidate { |candidate|
      put [$candidate current]
    } |
      make-map
  )

  var actual-candidate-map = (
    {
      put $current-based-map
      put $overriding-versions
    } |
      map:merge
  )

  var existing-candidate-paths = [(
    map:iterate $actual-candidate-map { |candidate version|
      var current-path = (get-candidate-dir $candidate &version=$version)

      var bin-path = (path:join $current-path bin)

      if (os:exists $bin-path) {
        put $bin-path
      } elif (os:exists $current-path) {
        put $current-path
      }
    }
  )]

  var candidates-hub = (path:join $sdkman-home candidates)

  var paths-without-candidates = [(
    all $paths |
      keep-if { |path|
        not (str:has-prefix $path $candidates-hub)
      }
  )]

  all $existing-candidate-paths
  all $paths-without-candidates
}

#
# Resets both the PATH and the *_HOME environment variables to the "current" version of each candidate,
# provided its file-system entry exists.
#
# The "overriding-versions" flag takes in input a <candidate><version> map - whose versions
# will replace the default, "current"-based paths.
#
# Anyway, only existing paths will be added to the PATH; similarly, if a candidate does not appear
# in the path, its *_HOME variable will be unset.
#
fn reset-vars { |&overriding-versions=[&]|
  set paths = [(-get-reset &overriding-versions=$overriding-versions)]

  setup-sdk-homes
}
