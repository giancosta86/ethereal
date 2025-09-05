use os
use ./fs

#TODO! Test this!
fn copy-to-jpeg { |@sources|
  each { |source|
    gm convert $source (fs:potential-ext $source '.jpg')
  } $sources
}

#TODO! Test this!
fn resize-to-copy { |@sources &percent=75|
  var target-dir = resized-$percent

  os:mkdir-all $target-dir

  each { |source|
    gm convert $source -resize $percent% $target-dir/$source
  } $sources
}