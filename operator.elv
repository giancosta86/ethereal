use ./lang
use ./seq

#
# Higher-order function emitting a multi-operand operator based on:
#
# * an `initial-result`, emitted by the operator if no value is passed
#
# * a `binary-operator`, iteratively taking the previous result (starting from `initial-result`)
#   and the current item
#
# The multi-operand operator indifferently supports either arguments or values passed via pipe.
#
fn multi-value { |initial-result binary-operator|
  put { |@arguments|
    lang:get-inputs $arguments |
      seq:reduce $initial-result $binary-operator
  }
}
