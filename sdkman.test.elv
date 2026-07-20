use path
use ./sdkman

>> 'In sdkman module' {
  >> 'invoking the command' {
    capture {
      sdkman:sdkman version
    } |
      should-contain SDKMAN
  }

  >> 'getting a specific SDK path' {
    sdkman:get-sdk-directory java 8.0.492.fx-zulu |
      should-be (path:join ~ .sdkman candidates java 8.0.492.fx-zulu)
  }
}