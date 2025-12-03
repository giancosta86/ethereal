use str
use ./edit
use ./fs

>> 'In edit module' {
  >> 'editing a text file' {
    >> 'when the transformer emits a string' {
      >> 'should replace the content' {
        fs:with-temp-file { |temp-path|
          var initial-value = Test

          print $initial-value > $temp-path

          edit:file $temp-path { |content|
            put 'X-'$content"\n\n--Y"
          }

          slurp < $temp-path |
            should-be 'X-'$initial-value"\n\n--Y"
        }
      }
    }

    >> 'when the transformer emits $nil' {
      >> 'should leave the content untouched' {
        fs:with-temp-file { |temp-path|
          var initial-value = Test

          print $initial-value > $temp-path

          edit:file $temp-path { |content|
            put $nil
          }

          slurp < $temp-path |
            should-be $initial-value
        }
      }
    }
  }

  >> 'editing a file via jq' {
    >> 'should apply the requested transform' {
      fs:with-temp-file { |temp-path|
        put [
          &alpha=90
          &beta=92
          &gamma=5
        ] |
          to-json > $temp-path

        slurp < $temp-path |
          str:contains (all) beta |
          should-be $true

        edit:json $temp-path 'del(.beta)'

        slurp < $temp-path |
          str:contains (all) beta |
          should-be $false
      }
    }
  }
}
