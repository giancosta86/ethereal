use str
use ./command
use ./diff

>> 'In diff module' {
  >> 'diff' {
    >> 'when the strings are equal' {
      command:capture {
        diff:diff &throw Alpha Alpha
      } |
        should-be [
          &data=[]
          &exception=$nil
        ]
    }

    >> 'when the strings are different' {
      var command-result = (
        command:capture {
          put Alpha Beta |
            diff:diff &throw
        }
      )

      var output = (str:join "\n" $command-result[data])

      str:contains $output '@@ -1 +1 @@' |
        should-be $true

      str:contains $output -Alpha |
        should-be $true

      str:contains $output +Beta |
        should-be $true

      put $command-result[exception] |
        should-be $nil
    }
  }
}