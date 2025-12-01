pragma unknown-command = disallow

var -configuration-path = ~/.curlrc

fn display-errors-only {
  echo '--silent --show-error' > $-configuration-path
}