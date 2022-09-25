# Demobox runner

A number of helper scripts for setting up VirtualBox based Virtual Machines running minimal Ubuntu Server OS installs.

Tested to support Windows (via Git Bash) and Linux.

# Usage

## Required tools

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (Tested with VirtualBox 6.1.38)
- (Windows only) [Git bash](https://git-scm.com/downloads) (Tested with 2.37.3)
- (Optional) A Linux machine with "genisoimage" for generating the "seed.iso" file

## System requirements

- On Windows, not running Hyper-V or "Docker for Desktop" (clashes with VirtualBox)

To run one instance of the Virtual machine, the following will be needed;

- Hard drive: 23GB free space (4 GB allocated up front by script)
- RAM: 2GB free
- CPU: 2 free cores

## Remote ISO packaging

The code includes an option to use a remote server to generate the "seed.iso" file. (Service: tools.stwcreation.com).

There is no guarantee as to the availability of this service. The alternative "build.sh" script in the "seed" folder
contains the necessary logic to prepare the files on an accessible Linux machine in its absence.

## On Windows

- Open "git bash"
- Navigate to the source
- Run the get-virtual-box.sh wrapper script

```
PATH_VBOX="/c/Program Files (x86)/Oracle/VirtualBox" ./get-virtual-box.sh
```

# License

Copyright 2022 Owen Davies

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
