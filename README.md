BitcoinHD Core Build
====================

For detailes compilation documents, see `build-*.md` under [btchd/doc](https://github.com/btchd/btchd/tree/master/doc).

Platforms
---------

Common `host-platform-triplets` for cross compilation are:

- `x86_64-w64-mingw32` for Windows 64 bit
- `i686-w64-mingw32` for Windows 32 bit
- `x86_64-apple-darwin14` for macOS 64 bit (The 32 bit binary has unsupported after macOS Catalina)
- `i686-linux-gnu` for Linux 32 bit
- `x86_64-linux-gnu` for Linux 64 bit
- `arm-linux-gnueabihf` for Linux ARM 32 bit
- `aarch64-linux-gnu` for Linux ARM 64 bit
- `riscv64-linux-gnu` for Linux RISC-V 64 bit

Build docker images
-------------------

The docker image base on `ubuntu:18.04`. Install docker and run `make images` command.

Build BitcoinHD binary
----------------------

- Download BitcoinHD source code by git: `git clone https://github.com/btchd/btchd.git`

- Run build command: `cd ./btchd && make -f /YourBuildScriptPath/Makefile`

You will see the `../btchd_build/release` directory, it's the compiled binary
package. If you want to compile the binary package of the specified platform,
you can use `cd ./btchd && make -f /YourBuildScriptPath/Makefile build_host-platform-triplets`.

Example: `cd ./btchd && make -f /YourBuildScriptPath/Makefile build_x86_64-w64-mingw32` only for Win64.
