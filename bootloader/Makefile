all: boot.bin
	@echo "Building kernel..."
	@powershell -Command "cd ../kernel; make all"
	@echo "Creating disk image..."
	@powershell -ExecutionPolicy Bypass -File create_disk.ps1

boot.bin: boot.asm
	@echo "Assembling bootloader..."
	@nasm -f bin boot.asm -o boot.bin

run: all
	@echo "Starting QEMU..."
	@qemu-system-i386 -drive format=raw,file=disk.img

clean:
	@echo "Cleaning bootloader..."
	@powershell -Command "Remove-Item boot.bin,disk.img -ErrorAction SilentlyContinue"
	@echo "Cleaning kernel..."
	@powershell -Command "cd ../kernel; make clean"

.PHONY: all run clean
