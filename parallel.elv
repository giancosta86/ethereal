use ./seq

var DEFAULT-NUM-WORKERS = 8

#
# Splits the values received *via pipe* into *chunks* - one chunk per *parallel worker* - then:
#
# 1. Calls `chunk-mapper` on each worker, passing it the chunk items as *varargs*:
#    the function must return a **chunk result** of any type.
#
# 2. Calls `joiner`, passing it the computed *chunk results* as *varargs*:
#    this function must return the **overall result** of arbitrary type.
#
# As usual, both `chunk-mapper` and `joiner` should be both *commutative* and *associative* with respect
# to the items and the chunk results.
#
fn fork-join { |&num-workers=$DEFAULT-NUM-WORKERS chunk-mapper joiner|
  all |
    seq:split-by-chunk-count $num-workers |
    peach &num-workers=$num-workers { |chunk|
      $chunk-mapper $@chunk
    } |
      $joiner (all)
}