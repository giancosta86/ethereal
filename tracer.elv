use ./console

fn create { |is-enabled-getter|
  put [
    &echo={ |@arguments|
      if ($is-enabled-getter) {
        console:echo $@arguments
      }
    }

    &print={ |@arguments|
      if ($is-enabled-getter) {
        console:print $@arguments
      }
    }

    &printf={ |&newline=$false template @values|
      if ($is-enabled-getter) {
        console:printf &newline=$newline $template $@values
      }
    }

    &pprint={ |@values|
      if ($is-enabled-getter) {
        console:pprint $@values
      }
    }

    &inspect={ |&emoji=🔎 description value|
      if ($is-enabled-getter) {
        console:inspect &emoji=$emoji $description $value
      }
    }

    &inspect-input-map={ |input-map|
      if ($is-enabled-getter) {
        console:inspect-input-map $input-map
      }
    }

    &section={ |&emoji=🔎 description string-or-block|
      if ($is-enabled-getter) {
        console:section &emoji=$emoji $description $string-or-block
      }
    }
  ]
}
