var -configuration-path = ~/.curlrc

fn disable-non-error-output {
  echo 📢 Configuring curl so that it outputs errors only... >&2

  echo '--silent --show-error' > $-configuration-path
}