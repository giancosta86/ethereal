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

fn get-minimal { |source|
  var source-kind = (kind-of $source)

  if (==s $source-kind list) {
    to-string [(all $source | each $get-minimal~)]
  } elif (==s $source-kind map) {
    to-string (
      map:map $source { |key value|
        put [(get-minimal $key) (get-minimal $value)]
      }
    )
  } else {
    to-string $source
  }
}

#TODO! Test this
fn indent-lines { |source-string indent|
  var partial-result = (
    put $source-string |
      to-lines |
      each { |line|
        if (!=s $line '') {
          echo $indent''$line
        } else {
          echo
        }
      } |
      slurp
  )

  put $partial-result[..-1]
}