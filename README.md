# k0 — A Simple x86 Kernel

This project is a minimal kernel written in C and Assembly, booted using limine and tested in QEMU. It's designed for learning the low-level fundamentals of operating systems.

---
## Requirements

Make sure the following packages are installed:

### Fedora:
```bash
sudo dnf install gcc binutils make grub2-tools-extra xorriso qemu-system-i386 wget curl
```

### Ubuntu/Debian
```bash
sudo apt install gcc binutils make grub-pc-bin xorriso qemu-system-i386 wget curl
```
## Step 1: Build the cross compiler
```bash
chmod u+x build-cross.sh
bash build-cross.sh
```
This will:
- Download and build binutils and gcc targeting i686-elf
- Install them into ./cross
- Leave your system GCC untouched

## Step 2: Build and run the kernel
```bash
make         # Builds everything and produces k0.iso
make run     # Boots it in QEMU
make clean   # Removes build artifacts (but keeps the toolchain)
make clean-cross   # Removes everything including the cross-compiler
```
