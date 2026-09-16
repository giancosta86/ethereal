use os
use path
use ../fs
use ./paths

#TODO! Remove candidates!
fn within-temp-sdkman-home { |&candidates=[] block|
  fs:within-temp-dir {
    tmp paths:sdkman-home = $pwd

    all $candidates | each { |candidate|
      paths:get-candidate-dir $candidate |
        os:mkdir-all (all)
    }

    $block
  }
}

fn get-current-link { |candidate &bin=$false|
  var link-base = (
    paths:get-candidate-dir $candidate |
      path:join (all) current
  )

  if $bin {
    path:join $link-base bin
  } else {
    put $link-base
  }
}

fn set-current { |candidate version|
  var current-link = (get-current-link $candidate)

  os:remove-all $current-link

  paths:get-candidate-dir $candidate &version=$version |
    os:symlink (all) $current-link
}

fn install { |candidate version &bin=$false &current=$true|
  var version-dir = (
    paths:get-candidate-dir $candidate &version=$version
  )

  if $bin {
    path:join $version-dir bin
  } else {
    put $version-dir
  } |
    os:mkdir-all (all)

  if $current {
    set-current $candidate $version
  }
}

fn uninstall { |candidate version|
  paths:get-candidate-dir $candidate &version=$version |
    os:remove-all (all)
}

fn get-path-entry { |candidate version &bin=$false|
  var version-dir = (paths:get-candidate-dir $candidate &version=$version)

  if $bin {
    path:join $version-dir bin
  } else {
    put $version-dir
  }
}
