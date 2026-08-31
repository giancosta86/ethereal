use ./command
use ./pdf

var pdfjam-spy = (command:spy)

>> 'In pdf module' {
  tmp pdf:-pdfjam~ = $pdfjam-spy[command]

  >> 'converting to A5' {
    >> 'should invoke the expected command for each file' {
      pdf:to-a5 Alpha.pdf Beta.pdf &scale=1.5

      $pdfjam-spy[get-runs] |
        should-be [
          [
            --outfile
            Alpha.a5.pdf
            --a5paper
            --scale
            1.5
            Alpha.pdf
          ]
          [
            --outfile
            Beta.a5.pdf
            --a5paper
            --scale
            1.5
            Beta.pdf
          ]
        ]
    }
  }
}