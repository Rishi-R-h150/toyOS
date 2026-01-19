all:
	nasm -f bin boot.asm -o boot.bin
	powershell -ExecutionPolicy Bypass -File create_disk.ps1

run: all
	qemu-system-i386 -drive format=raw,file=disk.img

clean:
	powershell -Command "Remove-Item boot.bin,disk.img -ErrorAction SilentlyContinue"
