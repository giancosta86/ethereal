use str
use ./lang
use ./seq
use ./set

var detect-kind~ -with-collection~ = (
  var supported-descriptors-by-kind = [
    &string=[
      &value-description=substring
      &is-empty=$seq:is-empty~
      &contains=$str:contains~
    ]

    &list=[
      &value-description=item
      &is-empty=$seq:is-empty~
      &contains=$has-value~
    ]

    &map=[
      &value-description=key
      &is-empty=$seq:is-empty~
      &contains=$has-key~
    ]

    &ethereal-set=[
      &value-description=item
      &is-empty=$set:is-empty~
      &contains=$set:has-value~
    ]
  ]

  #
  # Given a collection as input, emits the output of `kind-of` - with the exception of Ethereal sets,
  # for which it returns `ethereal-set`.
  #
  fn detect-kind { |@arguments|
    var subject = (lang:get-single-input $arguments)

    var subject-kind = (
      if (set:is-set $subject) {
        put ethereal-set
      } else {
        kind-of $subject
      }
    )

    if (not (has-key $supported-descriptors-by-kind $subject-kind)) {
      fail 'Data type not supported as a collection: '$subject-kind
    }

    put $subject-kind
  }

  fn -with-collection { |collection descriptor-consumer|
    var collection-kind = (detect-kind $collection)

    var collection-descriptor = $supported-descriptors-by-kind[$collection-kind]

    $descriptor-consumer $collection-descriptor
  }

  all [
    $detect-kind~
    $-with-collection~
  ]
)

#
# Given a collection as input, emits the lexical description
# for its values - for example, «item» for lists and «key» for maps.
#
fn get-value-description { |@arguments|
  var collection = (lang:get-single-input $arguments)

  -with-collection $collection { |descriptor|
    put $descriptor[value-description]
  }
}

#
# Given a collection as input, emits $true if it's empty - or $false otherwise.
#
fn is-empty { |@arguments|
  var collection = (lang:get-single-input $arguments)

  -with-collection $collection { |descriptor|
    $descriptor[is-empty] $collection
  }
}

#
# Given a collection as input, emits $true if it's non-empty - or $false otherwise.
#
fn is-non-empty { |@arguments|
  is-empty $@arguments |
    not (all)
 }

#
# Given a collection and a value as input, emits $true if the value belongs to the collection,
# or $false otherwise.
#
fn contains { |@arguments|
  var collection value = (
    lang:get-mixed-inputs &min-values=2 &max-values=2 &min-args=1 $arguments
  )

  -with-collection $collection { |descriptor|
    $descriptor[contains] $collection $value
  }
}
