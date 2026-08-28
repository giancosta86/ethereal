use path
use ./paths

>> 'For SDKMAN paths' {
  >> 'getting a specific SDK path' {
    >> 'when passing the version' {
        paths:get-sdk-directory java 25.0.4-tem |
          should-be (path:join $paths:sdkman-home candidates java 25.0.4-tem)
    }
  }
}