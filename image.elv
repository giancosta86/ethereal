use ./fs
use ./lang

var -gm~ = (external gm)

fn copy-to-jpeg { |&quality=85 @arguments|
  lang:get-inputs $arguments | each { |source-path|
    fs:switch-ext $source-path '.jpg' |
      -gm convert -quality $quality $source-path (all)
  }
}

fn resize-to-copy { |&new-percent=75 @arguments|
  lang:get-inputs $arguments | each { |source-path|
    var core ext = (fs:split-ext $source-path)

    var dest-path = $core-$new-percent''$ext

    -gm convert -resize $new-percent% $source-path $dest-path
  }
}