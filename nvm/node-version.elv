use os
use path
use re
use str
use ../console
use ../lang
use ../seq

fn -detect-from-package-json {
  if (not (os:is-regular package.json)) {
    put $nil
    return
  }

  var version-field = (
    jq -r '.engines.node // ""' package.json |
      str:trim-space (all) |
      seq:empty-to-default
  )

  re:find '.*?(\d+(?:\.\d+)*).*' $version-field | each { |match|
    put 'v'$match[groups][1][text]
  }
}

fn -detect-from-nvmrc {
  if (not (os:is-regular .nvmrc)) {
    put $nil
    return
  }

  var version = (
    slurp < .nvmrc |
      str:trim-space (all)
  )

  lang:ternary (seq:is-non-empty $version) $version $nil
}

fn detect-in-pwd {
  coalesce (
    -detect-from-nvmrc
  ) (
    -detect-from-package-json
  )
}

fn detect-recursively {
  var original-pwd = $pwd
  defer { set pwd = $original-pwd }

  while $true {
    var version = (detect-in-pwd)

    if $version {
      put $version
      return
    }

    var parent-dir = (path:dir $pwd)

    if (eq $parent-dir $pwd) {
      put $nil
      return
    }

    set pwd = $parent-dir
  }
}