# ARM MiniOS Assembler Shell

An educational bare-metal mini operating shell for ARMv5, built mainly in ARM assembly for the **Computer Fundamentals** coursework.

## What this project is

This repository implements a tiny command-line environment that runs on a minimal ARM runtime (no host OS, freestanding build). It prints a prompt through UART, reads user commands, and interprets basic shell-like instructions.

Core ideas demonstrated in this project:

- ARM assembly program structure (`startup`, `main`, command interpreter, utility routines)
- UART-based input/output for interactive console behavior
- Lightweight command parsing and execution
- Register-style virtual state management (`r0..r9`-like virtual registers)
- Mixed C + Assembly integration in a freestanding toolchain

## Implemented command set (current status)

The current interpreter includes support for commands such as:

- `help`
- `set r<n>=<value>`
- `input r<n>`
- `print "text"`
- `print r<n>`
- `list_reg`

> Note: The help text lists additional commands (`list_int`, `if`, `sleep`, environment variables) that are part of the broader course scope and may be partially implemented or pending.

## Repository structure

- `src/startup.s` — low-level startup code
- `src/main.s` — interactive command loop
- `src/interpreta.s` — command interpreter
- `src/utils.s` — helper/utility assembly routines
- `src/datos.s` — global messages, buffers, command literals
- `src/auxiliar.c` — C helper functions linked with assembly
- `memmap` — linker memory map script
- `Makefile` — build pipeline for test and main binaries

## Requirements

- GNU ARM cross-toolchain (for example one of):
  - `arm-linux-gnueabi-*` (default in `Makefile`)
  - `arm-none-eabi-*` (commented alternative in `Makefile`)
- `make`

## Build

```bash
make
```

Generated artifacts include:

- `main.elf`, `main.bin`, `main.list`
- `test.elf`, `test.bin`, `test.list`

## Clean

```bash
make clean
```

## Suggested GitHub metadata

If you are publishing this repository on GitHub, these metadata values are recommended:

- **Repository name**: `arm-minios-assembler-shell`
- **Description**: `Educational bare-metal ARMv5 mini shell in assembly with UART I/O, command parsing, and virtual register management.`
- **Topics**: `arm`, `armv5`, `assembly`, `bare-metal`, `embedded`, `uart`, `cross-compiler`, `operating-systems`, `computer-architecture`, `education`

## License

MIT License. See `LICENSE`.
