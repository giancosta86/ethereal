use re
use str
use ./map
use ./seq

fn empty-to-default { |&default=$nil &trim=$true source|
  var actual-source = (
    if $trim {
      str:trim-space $source
    } else {
      put $source
    }
  )

  seq:empty-to-default &default=$default $actual-source
}

#TODO! Test this!
fn get-minimal { |source|
  var source-kind = (kind-of $source)

  if (eq $source-kind list) {
    to-string [(all $source | each $get-minimal~)]
  } elif (eq $source-kind map) {
    map:filter-map $source { |key value|
      put [(get-minimal $key) (get-minimal $value)]
    } |
      to-string (all)
  } else {
    to-string $source
  }
}

#TODO! Test this!
fn indent-lines { |indent|
  var slurp-result = (
    to-lines |
      each { |line|
        if (eq $line '') {
          echo
        } else {
          echo $indent''$line
        }
      } |
      slurp
  )

  put $slurp-result[..-1]
}

#TODO! Test this!
fn unstyled { |source|
  re:replace '\x1b\[[0-9;]*m' '' $source
}