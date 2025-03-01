AS = as
LD = ld

all: image

bootsect: bootsect.S
	$(AS) --32 bootsect.S -o bootsect.o
	$(LD) -Ttext 0x7c00 --oformat binary bootsect.o -o bootsect
	sync

setup: setup.S
	$(AS) --32 setup.S -o setup.o
	$(LD) -Ttext 0x7e00 --oformat binary setup.o -o setup
	sync

kernel: kernel_entry.o
	$(LD) -T kernel.ld -o kernel.bin kernel_entry.o

image: bootsect setup kernel
	dd if=/dev/zero of=floppy.img bs=512 count=2880
	dd if=bootsect of=floppy.img conv=notrunc
	dd if=setup of=floppy.img seek=1 conv=notrunc
	dd if=kernel.bin of=floppy.img seek=2 conv=notrunc

clean:
	rm -f *.o bootsect setup kernel.bin floppy.img
