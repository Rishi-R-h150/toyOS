# Create a disk image with space for bootloader + kernel
# Bootloader: 1 sector, Kernel: 20 sectors, Extra: 5 sectors
# Total: 26 sectors = 13312 bytes
$diskSize = 26 * 512  # 26 sectors = 13312 bytes
$disk = New-Object byte[] $diskSize
[System.IO.File]::WriteAllBytes("disk.img", $disk)

# Read the bootloader
$boot = [System.IO.File]::ReadAllBytes("boot.bin")

# Write bootloader to first sector of disk image (sector 1)
for ($i = 0; $i -lt $boot.Length; $i++) {
    $disk[$i] = $boot[$i]
}

# Read the kernel (if it exists)
$kernelPath = "..\kernel\kernel.bin"
if (Test-Path $kernelPath) {
    $kernel = [System.IO.File]::ReadAllBytes($kernelPath)
    $kernelSize = $kernel.Length
    $maxKernelSize = 20 * 512  # 20 sectors = 10240 bytes
    
    if ($kernelSize -gt $maxKernelSize) {
        Write-Host "Warning: Kernel is larger than 20 sectors! Truncating..." -ForegroundColor Yellow
        $kernelSize = $maxKernelSize
    }
    
    # Write kernel to sectors 2-5 (starting at byte 512, sector 2)
    $kernelStart = 512  # Sector 2 starts at byte 512
    for ($i = 0; $i -lt $kernelSize; $i++) {
        if ($kernelStart + $i -lt $diskSize) {
            $disk[$kernelStart + $i] = $kernel[$i]
        }
    }
    
    Write-Host "Kernel written to disk ($kernelSize bytes)" -ForegroundColor Green
} else {
    Write-Host "Warning: kernel.bin not found. Disk will have empty kernel sectors." -ForegroundColor Yellow
}

# Write the combined disk image
[System.IO.File]::WriteAllBytes("disk.img", $disk)

Write-Host "Disk image created: disk.img (26 sectors)" -ForegroundColor Green
