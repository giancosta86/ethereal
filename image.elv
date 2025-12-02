use ./fs
use ./lang

pragma unknown-command = disallow

var -gm~ = (external gm)

#
# Uses gm to convert each of the input image paths to JPGs having the requested `quality`.
#
fn copy-to-jpeg { |&quality=85 @arguments|
  lang:get-inputs $arguments | each { |source-path|
    fs:switch-ext $source-path .jpg |
      -gm convert -quality $quality $source-path (all)
  }
}

#
# Uses gm to convert each of the input image paths to copies scaled to the given new percentage.
#
fn scale-to-copy { |&new-percent=75 @arguments|
  lang:get-inputs $arguments | each { |source-path|
    var core ext = (fs:split-ext $source-path)

    var dest-path = $core'.'$new-percent''$ext

    -gm convert -resize $new-percent% $source-path $dest-path
  }
}