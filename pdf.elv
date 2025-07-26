use path
use ./console
use ./fs

fn merge-in-range { |&separator='-' &delete-sources=$false min-inclusive max-inclusive|
  var source-files = [(
    range $min-inclusive (+ $max-inclusive 1) | each { |ordinal|
      fs:wildcard $ordinal''$separator'*.pdf'
    }
  )]

  console:inspect &emoji=📥 'Source PDF files' $source-files

  var partial-merge-path = (fs:temp-file-path 'merged-*.pdf')

  pdfunite $@source-files $partial-merge-path

  if $delete-sources {
    all $source-files | each $fs:rimraf~
  }

  put $partial-merge-path
}
