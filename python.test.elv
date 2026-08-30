use ./python

fn get-pip-arguments { |block|
  var spy = (command:spy)

  tmp python:-pip~ = $spy[command]

  $block

  $spy[get-runs] |
    all (all) |
    one
}

>> 'In python module' {
  >> 'downloading a package' {
    >> 'when requesting the latest version' {
      >> 'when requesting the binary' {
        get-pip-arguments {
          python:download-package info.gianlucacosta.iris
        } |
          should-be [
            download
            --no-deps
            info.gianlucacosta.iris
          ]
      }

      >> 'when requesting the sources' {
        get-pip-arguments {
          put info.gianlucacosta.iris |
            python:download-package &sources
        } |
          should-be [
            download
            --no-deps
            --no-binary
            :all:
            info.gianlucacosta.iris
          ]
      }
    }

    >> 'when not requesting the latest version' {
      >> 'when requesting the binary' {
        get-pip-arguments {
          python:download-package &version=1.0.0 info.gianlucacosta.iris
        } |
          should-be [
            download
            --no-deps
            info.gianlucacosta.iris==1.0.0
          ]
      }

      >> 'when requesting the sources' {
        get-pip-arguments {
          put info.gianlucacosta.iris |
            python:download-package &sources &version=1.0.0
        } |
          should-be [
            download
            --no-deps
            --no-binary
            :all:
            info.gianlucacosta.iris==1.0.0
          ]
      }
    }
  }

  >> 'enabling memory allocation tracing' {
    tmp E:PYTHONTRACEMALLOC = 0

    python:trace-malloc

    get-env PYTHONTRACEMALLOC |
      should-be 1
  }
}