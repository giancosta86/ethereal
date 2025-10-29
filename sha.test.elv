use ./sha

>> 'In sha module' {
  >> 'SHA256' {
    >> 'for string' {
      put 'Hello, world!' |
        sha:compute256 |
        should-be 315f5bdb76d078c43b8ac0064e4a0164612b1fce77c869345bfc94c75894edd3
    }

    >> 'for list' {
      sha:compute256 [Alpha Beta Gamma] |
        should-be 5083e706982202ecc44c1f77b09df15412e3df4d736c71c98f2c6bb799a31689
    }
  }
}
