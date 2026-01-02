all:
	nasm -f bin boot.asm -o boot.bin

run: all
	qemu-system-i386 -drive format=raw,file=boot.bin
