use re
use str
use ./lang
use ./seq

var -numeric-component-fragment = [
  '0'
  '|'
  '[1-9]\d*'
]

var -pre-release-fragment = [
  $@-numeric-component-fragment
  '|'
  '\d*[a-zA-Z-][0-9a-zA-Z-]*'
]

var -build-fragment = '[0-9a-zA-Z-]+'

var -pattern = (
  all [
    '^'
    'v?'
    '(?P<major>'
      $@-numeric-component-fragment
    ')'
    '(?:'
      '\.'
      '(?P<minor>'
        $@-numeric-component-fragment
      ')'
      '(?:'
        '\.'
        '(?P<patch>'
          $@-numeric-component-fragment
        ')'
      ')?'
    ')?'
    '(?:'
      '-'
      '(?P<prerelease>'
        '(?:'
          $@-pre-release-fragment
        ')'
        '(?:'
          '\.'
          '(?:'
            $@-pre-release-fragment
          ')'
        ')*'
      ')'
    ')?'
    '(?:'
      '\+'
      '(?P<build>'
        $-build-fragment
        '(?:'
          '\.'
          $-build-fragment
        ')*'
      ')'
    ')?'
    '$'
  ] |
    str:join ''
)

fn parse { |@arguments|
  var source = (lang:get-single-input $arguments)

  var match = (
    re:find $-pattern $source |
      lang:ensure-put
  )

  if (not $match) {
    fail 'Invalid semver value: '''$source'''!'
  }

  var groups = $match[groups]

  put [
    &major=(
      put $groups[1][text] |
      num (all)
    )

    &minor=(
      put $groups[2][text] |
        seq:coalesce-empty &default=0 |
        num (all)
    )

    &patch=(
      put $groups[3][text] |
        seq:coalesce-empty &default=0 |
        num (all)
    )

    &pre-release=(
      str:trim-space $groups[4][text] |
        seq:coalesce-empty
    )

    &build=(
      str:trim-space $groups[5][text] |
        seq:coalesce-empty
    )
  ]
}

fn to-string { |@arguments|
  var version = (lang:get-single-input $arguments)

  var result = $version[major]'.'$version[minor]'.'$version[patch]

  if $version[pre-release] {
    set result = $result'-'$version[pre-release]
  }

  if $version[build] {
    set result = $result'+'$version[build]
  }

  put $result
}

fn is-stable { |@arguments|
  var version = (lang:get-single-input $arguments)

  not (or $version[pre-release] $version[build])
}

fn is-new-major { |@arguments|
  var version = (lang:get-single-input $arguments)

  and (== $version[minor] 0) (== $version[patch] 0) (is-stable $version)
}

fn less-than { |left right|
  for component [major minor patch] {
    if (< $left[$component] $right[$component]) {
      put $true
      return
    } elif (> $left[$component] $right[$component]) {
      put $false
      return
    }
  }

  if (not $left[pre-release]) {
    put $false
    return
  }

  if (and $left[pre-release] (not $right[pre-release])) {
    put $true
    return
  }

  <s $left[pre-release] $right[pre-release]
}