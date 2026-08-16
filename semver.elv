use re
use str
use ./lang
use ./seq

pragma unknown-command = disallow

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
    '\b'
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
    '\b'
  ] |
    str:join ''
)

fn -from-match { |match|
  var groups = $match[groups]

  put [
    &major=(
      put $groups[1][text] |
      num (all)
    )

    &minor=(
      put $groups[2][text] |
        seq:empty-to-default &default=0 |
        num (all)
    )

    &patch=(
      put $groups[3][text] |
        seq:empty-to-default &default=0 |
        num (all)
    )

    &pre-release=(
      str:trim-space $groups[4][text] |
        seq:empty-to-default
    )

    &build=(
      str:trim-space $groups[5][text] |
        seq:empty-to-default
    )
  ]
}

#
# Parses the given input string and emits a semantic version, i.e., a map containing the following keys:
#
# * major: always a number, required.
#
# * minor: always a number, 0 if missing.
#
# * patch: always a number, 0 if missing.
#
# * pre-release: a string, or $nil if missing.
#
# * build: a string, or $nil if missing.
#
# The string to parse can contain an optional leading 'v', that will be ignored - but it can't contain other data.
#
# In case of invalid format, an exception is thrown.
#
fn parse { |@arguments|
  var source = (lang:get-single-input $arguments)

  var match = (
    re:find '^'$-pattern'$' $source |
      lang:ensure-put |
      one
  )

  if (not $match) {
    fail 'Invalid semver value: '''$source'''!'
  }

  -from-match $match
}

#
# Emits all the semver instances found at any position in the given source string.
#
fn find { |@arguments|
  var source = (lang:get-single-input $arguments)

  re:find $-pattern $source |
    each $-from-match~
}

#
# Receives as input a semantic version and converts it to string, as follows:
#
# * the leading "v" is *not* added
#
# * `<major>.<minor>.<patch>` is the base form
#
# * `<pre-release>` is added only if not $nil, with a leading `-`
#
# * `<build>` is added only if not $nil, with a leading `+`
#
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

#
# Given a version passed as input:
#
# * if '<major>' is zero, emit '0.<minor>'; for example: `0.2.3`->`0.2`
#
# * otherwise, just emit <major> as a string; for example: `1.2.3`->`1`
#
fn to-major-string { |@arguments|
  var version = (lang:get-single-input $arguments)

  if (> $version[major] 0) {
    put $version[major]
  } else {
    put '0.'$version[minor]
  }
}

#
# Emits $true if the version passed as input has both its `pre-release` and `build` components set to $nil.
#
fn is-stable { |@arguments|
  var version = (lang:get-single-input $arguments)

  not (or $version[pre-release] $version[build])
}

#
# Emits $true if the version **is stable** and has both the `minor` and `patch` components set to 0.
#
fn is-new-major { |@arguments|
  var version = (lang:get-single-input $arguments)

  and (== $version[minor] 0) (== $version[patch] 0) (is-stable $version)
}

#
# Returns $true if the lefthand version is less recent than the righthand one;
# it is designed to be passed as the `less-than` option of the `order` builtin function.
#
# In particular, the algorithm operates as follows:
#
# 1)If `major` is not equal, the smaller one comes first.
#
# 2)If `minor` is not equal, the smaller one comes first.
#
# 3)If `patch` is not equal, the smaller one comes first.
#
# 4)If either version has a `pre-release`, and the other does not, the former comes first.
#
# 5)Finally, a lexicographic comparison between the `pre-release` components is performed.
#
# Please, note: in accordance with the standard, the `build` component is *not* taken into account.
#
fn less-than { |@arguments|
  var left right = (lang:get-inputs $arguments)

  all [major minor patch] | each { |component|
    if (< $left[$component] $right[$component]) {
      put $true
      return
    } elif (> $left[$component] $right[$component]) {
      put $false
      return
    }
  }

  # At this point, both operands must have the same <major>, <minor> and <patch> components.
  #
  # Consequently, if the left operand does not have a pre-release,
  # it just can't be less than the right operand, because:
  #
  # * if the right operand does not have a pre-release, both versions will be equal, as `build` is not taken into account;
  #
  # * if the right operand has a pre-release, the right version will come first.
  #
  if (not $left[pre-release]) {
    put $false
    return
  }

  # At this point, the left operand certainly has a pre-release,
  # so a non-prelease right operand will always come later.
  #
  if (not $right[pre-release]) {
    put $true
    return
  }

  # Finally, the pre-release components are both present and
  # they must be compared lexicographically.
  #
  <s $left[pre-release] $right[pre-release]
}

#
# Emits $true if the string passed via pipe contains the given version (object or string),
# possibly preceded by "v"; otherwise - including if `version` is $nil - emits $false.
#
fn contains { |version|
  if (eq $version $nil) {
    put $false
    return
  }

  var source = (one)

  var version-string = (
    kind-of $version |
      lang:switch [
        &string={
          put $version
        }
        &map={
          to-string $version
        }
      ]
  )

  str:trim-left $version-string v |
    re:quote (all) |
    put '(?:^|\s)v?'(all)'(?:\s|$)' |
    re:match (all) $source
}