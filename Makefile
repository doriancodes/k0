# === Paths ===
CROSS_DIR := $(CURDIR)/cross-compilation
PREFIX    := $(CROSS_DIR)/cross-compiler
TARGET    := i686-elf
CC        := $(PREFIX)/bin/$(TARGET)-gcc
AS        := $(PREFIX)/bin/$(TARGET)-as
LD        := $(PREFIX)/bin/$(TARGET)-ld

KERNEL    := kernel.bin
ISO       := kerny.iso
GRUB_DIR  := isodir/boot/grub

all: $(ISO)

# === Build object files ===
boot.o: boot.s
	$(AS) --32 boot.s -o boot.o

kernel.o: kernel.c
	$(CC) -ffreestanding -c kernel.c -o kernel.o

# === Link the kernel binary ===
$(KERNEL): linker.d boot.o kernel.o
	$(LD) -m elf_i386 -T linker.d -o $(KERNEL) boot.o kernel.o

# === Build bootable ISO ===
$(ISO): $(KERNEL) grub.cfg
	mkdir -p $(GRUB_DIR)
	cp $(KERNEL) isodir/boot/kernel.bin
	cp grub.cfg $(GRUB_DIR)
	grub2-mkrescue -o $(ISO) isodir

# === Run with QEMU ===
run: $(ISO)
	qemu-system-i386 -cdrom $(ISO)

# === Clean build files ===
clean:
	rm -f *.o $(KERNEL) $(ISO)
	rm -rf isodir

# === Clean everything including cross compiler and build dirs ===
clean-cross: clean
	rm -rf $(CROSS_DIR)

.PHONY: all clean run clean-cross

