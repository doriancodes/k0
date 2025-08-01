# === Paths ===
SRC_DIR   := $(CURDIR)/src
BUILD_DIR := $(CURDIR)/build
CROSS_DIR := $(CURDIR)/cross-compilation
PREFIX    := $(CROSS_DIR)/cross-compiler

# === Toolchain ===
TARGET    := i686-elf
CC        := $(PREFIX)/bin/$(TARGET)-gcc
LD        := $(PREFIX)/bin/$(TARGET)-ld

# === Flags ===
CFLAGS = -ffreestanding -O2 -Wall -Wextra
LDFLAGS = -T linker.d -nostdlib

# === Files ===
SRC_C = $(SRC_DIR)/kernel.c $(SRC_DIR)/common.c $(SRC_DIR)/monitor.c $(SRC_DIR)/isr.c $(SRC_DIR)/descriptor_tables.c
SRC_S = $(SRC_DIR)/boot.s 
OBJ_C = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRC_C))
OBJ_S = $(patsubst $(SRC_DIR)/%.s, $(BUILD_DIR)/%.o, $(SRC_S))
OBJ = $(OBJ_C) $(OBJ_S)
ISO = k0.iso
ELF = k0.elf

# === Default Target ===
all: $(ISO)

# === Build object files ===
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -I $(SRC_DIR) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s | $(BUILD_DIR)
	$(CC) $(CFLAGS) -I $(SRC_DIR) -c $< -o $@

# === Link ELF ===
$(ELF): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

# === Build ISO ===
$(ISO): $(ELF)
	mkdir -p iso/boot/grub
	cp $< iso/boot/
	cp grub/grub.cfg iso/boot/grub/
	grub2-mkrescue -o $@ iso

# === Run QEMU ===
run: $(ISO)
	qemu-system-i386 -cdrom $(ISO)

# === Clean ===
clean:
	rm -rf build iso *.elf *.iso

.PHONY: all clean run
