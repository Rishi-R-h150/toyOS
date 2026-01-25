# Kernel Makefile
# Compiles and links the kernel

# Compiler and flags for freestanding C
CC = gcc
CFLAGS = -m32 -ffreestanding -nostdlib -nostdinc -fno-builtin -Wall -Wextra
LD = ld
OBJCOPY = objcopy

# Source files
KERNEL_SRC = kernel.c
KERNEL_OBJ = kernel.o
KERNEL_ELF = kernel.elf
KERNEL_BIN = kernel.bin

# Default target
all: $(KERNEL_BIN)

# Compile C source to object file
$(KERNEL_OBJ): $(KERNEL_SRC)
	@echo "Compiling kernel..."
	$(CC) $(CFLAGS) -c $(KERNEL_SRC) -o $(KERNEL_OBJ)

# Link object file to create ELF executable
$(KERNEL_ELF): $(KERNEL_OBJ) linker.ld
	@echo "Linking kernel..."
	$(LD) -m i386pe -T linker.ld $(KERNEL_OBJ) -o $(KERNEL_ELF)

# Convert ELF to flat binary
$(KERNEL_BIN): $(KERNEL_ELF)
	@echo "Converting to binary..."
	$(OBJCOPY) -O binary $(KERNEL_ELF) $(KERNEL_BIN)
	@echo "Kernel built: $(KERNEL_BIN)"

# Clean build files
clean:
	@powershell -Command "Remove-Item $(KERNEL_OBJ),$(KERNEL_ELF),$(KERNEL_BIN) -ErrorAction SilentlyContinue"
	@echo "Cleaned kernel build files"

.PHONY: all clean
