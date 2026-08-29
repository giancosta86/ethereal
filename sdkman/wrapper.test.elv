use ./wrapper

var sdkman~ = $wrapper:sdkman~

>> 'SDKMAN' {
  >> 'wrapper' {
    >> 'requesting the version' {
      capture {
        sdkman version
      } |
        should-contain SDKMAN
    }
  }
}