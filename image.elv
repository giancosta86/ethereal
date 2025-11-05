use ./fs
use ./lang

fn copy-to-jpeg { |&quality=85 @arguments|
  lang:get-inputs $arguments | each { |source-path|
    fs:switch-extension $source-path '.jpg' |
      gm convert -quality $quality $source-path (all)
  }
}

fn resize-to-copy { |&new-percent=75 @arguments|
  lang:get-inputs $arguments | each { |source-path|
    gm convert -resize $new-percent% $source-path $source-path'-'$new-percent
  }
}