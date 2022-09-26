# Demobox generator

A number of helper scripts for setting up VirtualBox based Virtual Machines running minimal Ubuntu Server OS installs
with custom tooling installed.

Tested to support Windows (via Git Bash) and Linux.

# System requirements

- On Windows, not running Hyper-V or "Docker for Desktop" (clashes with VirtualBox)

To run one instance of the Virtual machine, the following will be needed;

- Hard drive: 23GB free space (4 GB allocated up front by script)
- RAM: 2GB free
- CPU: 2 free cores

# Required tools

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (Tested with VirtualBox 6.1.38)
- (Windows only) [Git bash](https://git-scm.com/downloads) (Tested with 2.37.3)
- (Optional) A Linux machine with "genisoimage" for generating the "seed.iso" file

## Remote ISO packaging

The code includes an option to use a remote server to generate the "seed.iso" file. (Service: tools.stwcreation.com).

There is no guarantee as to the availability of this service. The alternative "build.sh" script in the "seed" folder
contains the necessary logic to prepare the files on an accessible Linux machine in its absence.

# How to use the instructions below

## "Open a terminal" meaning

For any instructions below, "Open a terminal" will mean either 

- opening "git bash" on Windows, or
- opening a native terminal on Linux, and 
- navigating to the root of the project.

# Setup Virtual Machine

## Part 1: Create Virtual Box

### On Windows

Open a terminal and run the following.
```
PATH_VBOX="/c/Program Files (x86)/Oracle/VirtualBox" ./setup-demobox.sh
```
### On Linux

Open a terminal and run the following.
```
./setup-demobox.sh
```
### Variables

The "setup-demobox.sh" script has the following optional variables (input as environment variables).

- PATH\_VBOX - Additional path to search for VirtualBox binaries.
- PATH\_DOWNLOADS - Location to store the compiled seed.iso and the downloaded VM image. Default "/tmp"
- VM\_NAME - Name of VirtualMachine. Default "demobox".
- VM\_CPU - Number of CPU cores to allocate. Default "2".
- VM\_HDD - Resize hard drive size from 10GB original image (in megabytes). Default "20000".
- VM\_RAM - Megabytes of RAM allocated to VM. Default "2048".
- VM\_SSH - Local port for port forwarding. Default "2222". Cannot be used by multiple machines.

### Flags

The "setup-demobox.sh" script has the following optional flags.

- \-s - Skip checks of whether Virtual Machine has already been imported. Mostly used for debugging.
- \-f - Force replacement of Virtual Machine if it already exists. Cowardly refuses to overwrite without flag.

## Part 2 : Installer scripts

Several optional scripts are available to configure the Virtual Machine for a specific workload.

### Docker
Open a terminal and run the following.
```
tool/copy-and-run.sh 2222 "install/docker.sh"
```

## Part 3 : Connecting via SSH

To use the Virtual Machine, connection is made over the network using SSH.

For authorisation, the Virtual Machine is configured with a dedicated SSH public key on setup.

For network access, the Virtual Machine is configured to portforward a local port to the remote SSH port. The
default port is 2222.

Connecting can be done via any SSH compatible program (e.g., PuTTY) using the details `pineapple@127.0.0.1 -p 2222 -i ~/.ssh/id_busybox`.

Alternatively, a wrapper script is provided to connect for you.

Open a terminal and run the following.
```
tool/ssh.sh 2222
```

# License

Copyright 2022 Owen Davies

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
