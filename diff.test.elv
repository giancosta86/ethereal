use ./diff

>> 'In diff module' {
  >> 'diff' {
    >> 'when the strings are equal' {
      var output-tester = (
        diff:diff &throw Alpha Alpha |
          output-tester:create
      )

      put $output-tester[text] |
        should-be ''
    }

    >> 'when the strings are different' {
      var output-tester = (
        put Alpha Beta |
          diff:diff &throw |
          output-tester:create &unstyled
      )

      $output-tester[should-contain-all] [
        '@@ -1 +1 @@'
        -Alpha
        +Beta
      ]
    }
  }
}