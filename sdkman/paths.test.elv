use path
use ./paths

>> 'SDKMAN' {
  >> 'paths' {
    >> 'getting a specific SDK path' {
      paths:get-sdk-directory java 25.0.4-tem |
        should-be (path:join $paths:sdkman-home candidates java 25.0.4-tem)
    }
  }
}