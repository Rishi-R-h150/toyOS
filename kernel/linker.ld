/*
 * Linker Script for Kernel
 * 
 * This tells the linker where to place code in memory.
 * Critical: Kernel must start at 0x10000 (where bootloader loads it)
 */

/* Entry point - this function will be called first */
ENTRY(kernel_entry)

/* Define memory sections */
SECTIONS
{
    /* Start at 0x10000 - this is where bootloader loads kernel */
    . = 0x10000;
    
    /* Code section - all executable code goes here */
    .text : {
        *(.text)           /* All .text sections from object files */
    }
    
    /* Initialized data section - global variables with values */
    .data : {
        *(.data)           /* All .data sections */
    }
    
    /* Uninitialized data section - global variables without values */
    .bss : {
        *(.bss)            /* All .bss sections */
    }
    
    /* End of kernel - we can use this later to know kernel size */
    kernel_end = .;
}
