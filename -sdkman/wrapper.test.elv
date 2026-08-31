use ./wrapper

var sdk~ = $wrapper:sdk~

>> 'SDKMAN' {
  >> 'wrapper' {
    >> 'requesting the version' {
      capture {
        sdk version
      } |
        should-contain SDKMAN
    }
  }
}