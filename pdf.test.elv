use ./command
use ./pdf

var pdf-jam-spy = (command:spy)
set pdf:-pdfjam~ = $pdf-jam-spy[command]

>> 'In pdf module' {
  >> 'converting to A5' {
    >> 'should invoke the expected command for each file' {
      pdf:to-a5 Alpha.pdf Beta.pdf &scale=1.5

      $pdf-jam-spy[get-runs] |
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