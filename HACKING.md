# Kernel Hacker's Guide

## Register sizes

Kernel assumes both accumulator and index registers are 16bit.
If you need to deal with 8-bit numbers, switch to `_a8` and then switch
back to `_a16` before returning.

To facilitate this, start your code block with:

```
.code
.a16
.i16
```

## Calling Conventions

Kernel procedures are caller-registers-preserve.
Kernel is calling only code under its own control. External code interface is
through `COP`-trap only.
This allows for optimizations of registers preservation. If you don't care
about register values when calling the procedure, you don't need to preserve
anything. You can see what registers are being clobbered and choose proper
action before JSR.
