use path
use ./sdkman
use ./sdkman/paths

>> 'In sdkman module' {
  >> 'getting a specific SDK path' {
    >> 'when passing the version' {
      sdkman:get-sdk-directory java 8.0.492.fx-zulu |
        should-be (path:join $paths:sdkman-home candidates java 8.0.492.fx-zulu)
    }
  }
}