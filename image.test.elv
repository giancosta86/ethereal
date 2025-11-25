use ./command
use ./image

fn get-gm-runs { |block|
  var spy = (command:spy)

  tmp image:-gm~ = $spy[command]

  $block

  $spy[get-runs]
}

>> 'In image module' {
  >> 'when copying to jpg' {
    >> 'when the source is a single image' {
      get-gm-runs {
        image:copy-to-jpeg dodo.png
      } |
        should-be [
          [
            convert
            -quality
            85
            dodo.png
            dodo.jpg
          ]
        ]
    }

    >> 'when the source consists of multiple images' {
      get-gm-runs {
        put alpha.png beta.bmp gamma.tiff |
          image:copy-to-jpeg &quality=72
      } |
        should-be [
          [
            convert
            -quality
            72
            alpha.png
            alpha.jpg
          ]
          [
            convert
            -quality
            72
            beta.bmp
            beta.jpg
          ]
          [
            convert
            -quality
            72
            gamma.tiff
            gamma.jpg
          ]
        ]
    }
  }

  >> 'when resizing to a copy' {
    >> 'when the source is a single image' {
      get-gm-runs {
        image:scale-to-copy dodo.png
      } |
        should-be [
          [
            convert
            -resize
            75%
            dodo.png
            dodo.75.png
          ]
        ]
    }

    >> 'when the source consists of multiple images' {
      get-gm-runs {
        put alpha.png beta.tiff |
          image:scale-to-copy &new-percent=63
      } |
        should-be [
          [
            convert
            -resize
            63%
            alpha.png
            alpha.63.png
          ]
          [
            convert
            -resize
            63%
            beta.tiff
            beta.63.tiff
          ]
        ]
    }
  }
}