use str
use ./edit
use ./fs

>> 'In edit module' {
  >> 'editing a text file' {
    >> 'when the transformer emits a string' {
      >> 'should replace the content' {
        fs:with-temp-file { |temp-path|
          print 'Test' > $temp-path

          edit:file $temp-path { |content|
            put 'X-'$content"\n\n--Y"
          }

          var new-content = (slurp < $temp-path)

          put $new-content |
            should-be "X-Test\n\n--Y"
        }
      }
    }

    >> 'when the transformer emits $nil' {
      >> 'should leave the content untouched' {
        fs:with-temp-file { |temp-path|
          var initial-value = 'Test'

          print $initial-value > $temp-path

          edit:file $temp-path { |content|
            put $nil
          }

          var new-content = (slurp < $temp-path)

          put $new-content |
            should-be $initial-value
        }
      }
    }
  }

  >> 'editing a file via jq' {
    >> 'should apply the requested transform' {
      fs:with-temp-file { |temp-path|
        echo '{ "alpha": 90, "beta": 92, "gamma": 95 }' > $temp-path

        slurp < $temp-path |
          str:contains (all) 'beta' |
          should-be $true

        edit:json $temp-path 'del(.beta)'

        slurp < $temp-path |
          str:contains (all) 'beta' |
          should-be $false
      }
    }
  }
}
