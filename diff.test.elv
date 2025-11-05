use str
use ./command
use ./diff

>> 'In diff module' {
  >> 'diff' {
    >> 'when the strings are equal' {
      command:capture {
        diff:diff Alpha Alpha
      } |
        should-be [
          &output=''
          &exception=$nil
        ]
    }

    >> 'when the strings are different' {
      var command-result = (
        command:capture {
          diff:diff Alpha Beta
        }
      )

      str:contains $command-result[output] '@@ -1 +1 @@' |
        should-be $true

      str:contains $command-result[output] -Alpha |
        should-be $true

      str:contains $command-result[output] +Beta |
        should-be $true

      put $command-result[exception] |
        should-be $nil
    }
  }
}