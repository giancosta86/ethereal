use ./pipx

pragma unknown-command = disallow

fn get-pipx-runs { |block|
  var spy = (command:spy)

  tmp pipx:-pipx~ = $spy[command]

  $block

  $spy[get-runs]
}

>> 'In pipx module' {
  >> 'qualifying a package' {
    >> 'with version' {
      pipx:qualify pdm &version=2.28.2 |
        should-be pdm==2.28.2
    }

    >> 'without version' {
      pipx:qualify pdm |
        should-be pdm
    }
  }

  >> 'running pipx' {
    >> 'when installed' {
      tmp pipx:-is-installed~ = { put $true }

      tmp pipx:-install~ = { fail 'This should not run!' }

      get-pipx-runs {
        pipx:pipx --version
      } |
        should-be [
          [--version]
        ]
    }

    >> 'when not installed' {
      var install-executed = $false

      tmp pipx:-is-installed~ = { put $false }

      tmp pipx:-install~ = { set install-executed = $true }

      get-pipx-runs {
        pipx:pipx install numpy
      } |
        should-be [
          [
            install
            numpy
          ]
        ]

      put $install-executed |
        should-be $true
    }
  }

  >> 'installing a package' {
    tmp pipx:-is-installed~ = { put $true }

    >> 'with version' {
      get-pipx-runs {
        pipx:install pdm &version=2.28.2
      } |
        should-be [
          [
            install
            pdm==2.28.2
          ]
        ]
    }

    >> 'without version' {
      get-pipx-runs {
        pipx:install pdm
      } |
        should-be [
          [
            install
            pdm
          ]
        ]
    }
  }

  >> 'getting a command' {
    tmp pipx:-is-installed~ = { put $true }

    >> 'with version' {
      var pdm~ = $nil

      get-pipx-runs {
        set pdm~ = (pipx:get-command pdm &version=2.28.2)
      } |
        should-be []

      get-pipx-runs {
        pdm run verify
      } |
        should-be [
          [
            run
            --quiet
            pdm==2.28.2
            run
            verify
          ]
        ]
    }

    >> 'without version' {
      var pdm~ = $nil

      get-pipx-runs {
        set pdm~ = (pipx:get-command pdm)
      } |
        should-be []

      get-pipx-runs {
        pdm run verify
      } |
        should-be [
          [
            run
            --quiet
            pdm
            run
            verify
          ]
        ]
    }
  }
}