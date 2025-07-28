# === Paths ===
CROSS_DIR := $(CURDIR)/cross-compilation
PREFIX    := $(CROSS_DIR)/cross-compiler
TARGET    := x86_64-elf
CC        := $(PREFIX)/bin/$(TARGET)-gcc
LD        := $(PREFIX)/bin/$(TARGET)-ld

KERNEL    := kerny.elf
ISO       := kerny.iso
ISO_DIR   := iso_root

CFLAGS    := -O2 -ffreestanding -Wall -Wextra -mno-red-zone -m64
LDFLAGS   := -nostdlib -T linker.d

# === Local Limine paths ===
LIMINE_DIR      := $(CURDIR)/limine
LIMINE_BIN      := $(LIMINE_DIR)/limine
LIMINE_SYS      := $(LIMINE_DIR)/limine-bios.sys
LIMINE_CD       := $(LIMINE_DIR)/limine-bios-cd.bin
LIMINE_EFI      := $(LIMINE_DIR)/limine-uefi-cd.bin
LIMINE_EFI64    := $(LIMINE_DIR)/BOOTX64.EFI
LIMINE_EFI32    := $(LIMINE_DIR)/BOOTIA32.EFI
LIMINE_CONF     := limine.conf
LIMINE_BOOT_DIR := $(ISO_DIR)/boot/limine

all: $(ISO)

# === Setup limine bootloader ===
# Only clone Limine if not present
$(LIMINE_DIR):
	git clone https://github.com/limine-bootloader/limine.git --branch=v9.x-binary --depth=1 $(LIMINE_DIR)

# Only build Limine if binary does not exist
$(LIMINE_BIN): | $(LIMINE_DIR)
	$(MAKE) -C $(LIMINE_DIR)

# === Build object files ===
kernel.o: kernel.c
	$(CC) $(CFLAGS) -c $< -o $@

# === Link kernel ===
$(KERNEL): kernel.o
	$(LD) $(LDFLAGS) -o $@ $^

# === Build ISO ===
$(ISO): $(KERNEL) $(LIMINE_CONF) $(LIMINE_BIN)
	# Create a directory which will be our ISO root.
	mkdir -p $(ISO_DIR)/boot

	# Copy the relevant files over.
	cp -v $(KERNEL) $(ISO_DIR)/boot/
	mkdir -p $(LIMINE_BOOT_DIR)
	cp -v $(LIMINE_CONF) $(LIMINE_SYS) $(LIMINE_CD) $(LIMINE_EFI) $(LIMINE_BOOT_DIR)/

	# Create the EFI boot tree and copy Limine's EFI executables over.
	mkdir -p $(ISO_DIR)/EFI/BOOT
	cp -v $(LIMINE_EFI64) $(ISO_DIR)/EFI/BOOT/
	cp -v $(LIMINE_EFI32) $(ISO_DIR)/EFI/BOOT/

	# Create the bootable ISO.
	xorriso -as mkisofs -R -r -J \
		-b boot/limine/$(notdir $(LIMINE_CD)) \
		-no-emul-boot -boot-load-size 4 -boot-info-table -hfsplus \
		-apm-block-size 2048 \
		--efi-boot boot/limine/$(notdir $(LIMINE_EFI)) \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		$(ISO_DIR) -o $(ISO)

	# Install Limine stage 1 and 2 for legacy BIOS boot.
	$(LIMINE_BIN) bios-install $(ISO)

# === Run with QEMU (UEFI)
run: $(ISO)
	qemu-system-x86_64 -cdrom $(ISO) -bios /usr/share/OVMF/OVMF_CODE.fd

# === Cleanup ===
clean:
	rm -f *.o $(KERNEL)
	rm -rf $(ISO_DIR)
	rm -f $(ISO)

clean-cross: clean
	rm -rf $(CROSS_DIR)

.PHONY: all clean run clean-cross

