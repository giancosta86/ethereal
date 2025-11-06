use ./console

var -configuration-path = ~/.curlrc

fn disable-non-error-output {
  console:echo 📢 Configuring curl so that it outputs errors only...

  echo '--silent --show-error' > $-configuration-path
}