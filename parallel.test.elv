use ./parallel
use ./seq

fn generate-test-range {
  range 1 1000
}

>> 'In parallel module' {
  >> 'running fork-join' {
    var expected-result = (
      generate-test-range |
        seq:reduce 0 $'+~'
    )

    >> 'should support single worker' {
      generate-test-range |
        parallel:fork-join &num-workers=1 $'+~' $'+~' |
        should-be $expected-result
    }

    >> 'should support multiple workers in parallel' {
      generate-test-range |
        parallel:fork-join &num-workers=8 $'+~' $'+~' |
        should-be $expected-result
    }
  }
}