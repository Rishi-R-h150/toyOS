# Create a 10-sector disk image (5120 bytes) filled with zeros
$diskSize = 5120  # 10 sectors * 512 bytes
$disk = New-Object byte[] $diskSize
[System.IO.File]::WriteAllBytes("disk.img", $disk)

# Read the bootloader
$boot = [System.IO.File]::ReadAllBytes("boot.bin")

# Write bootloader to first sector of disk image
for ($i = 0; $i -lt $boot.Length; $i++) {
    $disk[$i] = $boot[$i]
}

# Write the combined disk image
[System.IO.File]::WriteAllBytes("disk.img", $disk)

Write-Host "Disk image created: disk.img (10 sectors)"
