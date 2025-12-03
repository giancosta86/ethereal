pragma unknown-command = disallow

var -configuration-path = ~/.curlrc

#
# Configures curl so that it only shows errors.
#
fn display-errors-only {
  echo '--silent --show-error' > $-configuration-path
}