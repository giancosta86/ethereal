use ./diff

>> 'In diff module' {
  >> 'diff' {
    >> 'when the strings are equal' {
      capture {
        diff:diff &throw Alpha Alpha
      } |
        should-be ''
    }

    >> 'when the strings are different' {
      capture {
        put Alpha Beta |
          diff:diff &throw
      } |
        should-contain-all [
          '@@ -1 +1 @@'
          -Alpha
          +Beta
        ]
    }
  }
}