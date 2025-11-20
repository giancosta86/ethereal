# ethereal

_Elegant utilities for the Elvish shell_

## Installation

The library can be installed via **epm** - in particular:

```elvish
use epm

epm:install github.com/giancosta86/ethereal
```

even better, if you have [epm-plus](https://github.com/giancosta86/epm-plus), you can run:

```elvish
epm:install github.com/giancosta86/ethereal@v1
```

## Usage

This section only contains very high-level descriptions; for details about using each module, please refer to:

- the source module itself

- even more, the related **.test.elv** test script - based on the [Velvet](https://github.com/giancosta86/velvet) test framework

### Input values

Several functions take **input values**, from either:

- the argument list

- a pipe

although not from both at the same time.

For example, via argument list:

```elvish
exception:is-return ?(fail DODO) |
  should-be $true
```

whereas via pipe:

```elvish
put ?(fail DODO) |
  exception:is-return |
  should-be $true
```

### Modules

- [curl](curl.elv): utilities for the `curl` command-line client.

- [diff](diff.elv): easy way to apply the **diff** system command to two arbitrary values.

- [exception](exception.elv): exception type checking and metadata.

- [fake-git](fake-git.elv): tiny, customizable subset of the Git command.

- [lang](lang.elv): core, almost language-related utilities.

- [resources](resources.elv): convenient way to access the resources associated with a script file.

- [sha](sha.elv): computation of SHA hash codes.

- [string](string.elv): string manipulation.
