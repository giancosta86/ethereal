use os
use str
use ./command
use ./curl
use ./fs

>> 'In curl model' {
  >> 'when not disabling the progress' {
    fs:with-file-sandbox $curl:-configuration-path {
      os:remove-all $curl:-configuration-path

      command:capture &keep-stream=err {
        curl gianlucacosta.info
      } |
        put (all)[output] |
        str:contains (all) '%' |
          should-be $true
    }
  }

  >> 'when disabling the progress' {
    fs:with-file-sandbox $curl:-configuration-path {
      os:remove-all $curl:-configuration-path

      curl:disable-non-error-output

      command:capture &keep-stream=err {
        curl gianlucacosta.info
      } |
        put (all)[output] |
        str:contains (all) '%' |
          should-be $false
    }
  }
}