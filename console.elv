use builtin
use str
use ./lang
use ./string

fn echo { |@arguments|
  builtin:echo $@arguments > &2
}

fn print { |@arguments|
  builtin:print $@arguments > &2
}

fn printf { |&newline=$false template @values|
  builtin:printf $template $@values > &2

  if $newline {
    echo
  }
}

fn pprint { |@values|
  builtin:pprint $@values > &2
}

fn inspect { |&emoji=🔎 description value|
  printf '%s %s: ' $emoji $description

  pprint $value
}

fn inspect-input-map { |input-map|
  inspect &emoji=📥 'Input map' $input-map
}

fn section { |&emoji=🔎 description string-or-block|
  echo $emoji' '$description":"

  if (lang:is-function $string-or-block) {
    $string-or-block > &2
  } else {
    echo $string-or-block
  }

  echo (str:repeat $emoji 3)
}
