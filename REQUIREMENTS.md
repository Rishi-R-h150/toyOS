# Project Requirements

This document lists all the tools and dependencies needed to build and run the toyOS project.

## Required Tools

### 1. **NASM (Netwide Assembler)**
   - **Purpose**: Assembles the bootloader (boot.asm) into binary format
   - **Version**: 2.15+ recommended
   - **Windows Installation**:
     - Download from: https://www.nasm.us/pub/nasm/releasebuilds/
     - Or use package manager: `winget install NASM.NASM`
     - Add to PATH: `C:\Program Files\NASM` (or your installation path)
   - **Linux Installation**: `sudo apt-get install nasm` (Ubuntu/Debian)
   - **macOS Installation**: `brew install nasm`
   - **Verify**: Run `nasm --version`

### 2. **QEMU (Quick Emulator)**
   - **Purpose**: Emulates x86 hardware to run and test the OS
   - **Version**: 6.0+ recommended
   - **Windows Installation**:
     - Download from: https://www.qemu.org/download/#windows
     - Or use package manager: `winget install SoftwareFreedomConservancy.QEMU`
     - Add to PATH: `C:\Program Files\qemu` (or your installation path)
   - **Linux Installation**: `sudo apt-get install qemu-system-x86`
   - **macOS Installation**: `brew install qemu`
   - **Verify**: Run `qemu-system-i386 --version`

### 3. **Make (Build Automation)**
   - **Purpose**: Automates the build process (compiles bootloader, creates disk image)
   - **Version**: 3.81+ recommended
   - **Windows Installation**:
     - Download GnuWin32 Make: https://gnuwin32.sourceforge.net/packages/make.htm
     - Or use package manager: `winget install GnuWin32.Make`
     - Add to PATH: `C:\Program Files (x86)\GnuWin32\bin`
   - **Linux Installation**: Usually pre-installed, or `sudo apt-get install make`
   - **macOS Installation**: Usually pre-installed with Xcode Command Line Tools
   - **Verify**: Run `make --version`

### 4. **PowerShell (Windows only)**
   - **Purpose**: Required for disk image creation script (create_disk.ps1)
   - **Windows**: Pre-installed on Windows 10/11
   - **Verify**: Run `powershell --version`

## Future Requirements (For Later Phases)

These tools will be needed as the project progresses:

### 5. **GCC (GNU Compiler Collection) - Cross Compiler**
   - **Purpose**: Compile kernel code (C) for x86 architecture
   - **When Needed**: Phase 2 (Kernel Skeleton) onwards
   - **Installation**: 
     - Windows: Install MinGW-w64 or use WSL
     - Linux: `sudo apt-get install gcc-multilib`
     - macOS: `brew install gcc`

### 6. **GDB (GNU Debugger)**
   - **Purpose**: Debug the kernel during development
   - **When Needed**: Phase 2 onwards (optional but recommended)
   - **Installation**:
     - Windows: Install with MinGW or use WSL
     - Linux: `sudo apt-get install gdb`
     - macOS: `brew install gdb`

### 7. **GNU Binutils**
   - **Purpose**: Linker (ld) and other binary utilities
   - **When Needed**: Phase 2 (Kernel Skeleton) onwards
   - **Installation**: Usually comes with GCC or MinGW

## Quick Setup Checklist

- [ ] Install NASM and verify: `nasm --version`
- [ ] Install QEMU and verify: `qemu-system-i386 --version`
- [ ] Install Make and verify: `make --version`
- [ ] (Windows) PowerShell should already be installed
- [ ] Add all tools to system PATH
- [ ] Restart terminal/PowerShell after PATH changes

## Verification Command

Run this command to verify all Phase 1 tools are installed:

```bash
# Windows PowerShell
nasm --version; qemu-system-i386 --version; make --version

# Linux/macOS
nasm --version && qemu-system-i386 --version && make --version
```

All three commands should execute without errors.

## Troubleshooting

### "Command not found" errors
- Ensure tools are added to system PATH
- Restart terminal after PATH changes
- Verify installation paths are correct

### PowerShell execution policy errors
- Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Or run scripts with: `powershell -ExecutionPolicy Bypass -File script.ps1`

### QEMU not starting
- Ensure QEMU is in PATH
- Try full path: `C:\Program Files\qemu\qemu-system-i386.exe`

## Project Structure

```
toy-os/
├── bootloader/
│   ├── boot.asm          # Bootloader source code
│   ├── boot.bin          # Compiled bootloader (generated)
│   ├── disk.img          # Disk image (generated)
│   ├── create_disk.ps1   # Disk image creation script
│   └── Makefile          # Build automation
└── REQUIREMENTS.md       # This file
```

## Build Commands

Once all requirements are installed:

```bash
# Build bootloader and create disk image
make all

# Build and run in QEMU
make run

# Clean build files
make clean
```
