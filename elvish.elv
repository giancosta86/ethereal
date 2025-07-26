#TODO! Test this!

fn run-transform { |code inputs|
  var inputs-json = (put $inputs | to-json)

  var outputs-json = (elvish -c $code $inputs-json)

  echo $outputs-json | from-json
}