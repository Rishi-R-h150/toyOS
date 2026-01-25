/*
 * Kernel Entry Point
 * 
 * This is the first C function that executes after the bootloader.
 * The bootloader jumps to this function at address 0x10000.
 * 
 * This is freestanding C - no standard library, no main(), no runtime.
 */

/* Kernel entry point - called directly by bootloader */
void kernel_entry(void) {
    /* For now, just halt in an infinite loop */
    /* Later (Phase K1), we'll add VGA output here */
    
    while(1) {
        /* Infinite loop = halt
         * CPU will stay here until interrupted or reset
         * This is safe - no triple fault, no crash
         */
    }
    
    /* Kernel should never return */
}
