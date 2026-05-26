use ./fs
use ./writer

>> 'In writer module' {
  >> 'the out writer' {
    >> 'should write to stdout' {
      capture &stream=out {
        $writer:out { echo Dodo }
      } |
        should-be Dodo
    }
  }

  >> 'the err writer' {
    >> 'should write to stderr' {
      capture &stream=err {
        $writer:err { echo Dodo }
      } |
        should-be Dodo
    }
  }

  >> 'creating a writer to file' {
    >> 'should append to such file' {
      fs:with-temp-file { |temp-file|
        var file-writer = (writer:to-file $temp-file)

        $file-writer { echo Hello }
        $file-writer { echo World }

        slurp < $temp-file |
          should-be "Hello\nWorld\n"
      }
    }
  }
}