OUTPUT_FORMAT("binary")
ENTRY(_start)

SECTIONS
{
    . = 0x0000;
    _start = .;
    
    .text : {
        bootsect.o(.text)
        bootsect.o(.rodata)
        bootsect.o(.data)
        FILL(0x00);
        . = 510;
        SHORT(0xAA55);
        setup.o(.text)
        FILL(0x00);
        . = 0x8000;
    }
}
