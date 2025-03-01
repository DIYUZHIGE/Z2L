	BOOTSEG = 0x7c0			# Boot segment address
	INITSEG = 0x9000			# Initialization segment address
	SETUPLEN = 4				# Number of sectors for setup
	SETUPSEG = 0x9020			# Setup segment address

	SYSSEG = 0x1000				# System segment address

	.code16						# 16-bit code
	.text

	.global _start
_start:
	jmpl $BOOTSEG, $start2		# Jump to relocated code
	
start2:
	movw $BOOTSEG, %ax		# Move boot segment to AX
	movw %ax, %ds				# Set data segment to boot segment

	movw $INITSEG, %ax		# Move initialization segment to AX
	movw %ax, %es				# Set extra segment to initialization segment

	movw $256, %cx				# Set counter for 256 words

	subw %si, %si				# Clear source index
	subw %si, %di				# Clear destination index

	rep
	movsw					# Copy boot sector to new location

	jmpl $INITSEG, $go		# Jump to new location

go:
	movw %cs, %ax				# Move code segment to AX
	movw %ax, %ds				# Set data segment
	movw %ax, %es				# Set extra segment
	movw %ax, %ss				# Set stack segment
	movw $0xff00, %sp		# Set stack pointer

load_setup:
	movw $0x0000, %dx		# Drive 0, head 0
	movw $0x0002, %cx		# Cylinder 0, sector 2
	movw $0x0200, %bx		# Buffer address

	movb $SETUPLEN, %al		# Number of sectors to read
	movb $0x02, %ah			# BIOS read sector function
	int $0x13				# BIOS disk interrupt
	jnc ok_load_setup		# Jump if no error
	movw $0x0000, %dx		# Reset disk system
	movw $0x0000, %ax
	int $0x13
	jmp load_setup			# Retry loading

ok_load_setup:
	movw $msg, %ax				# Move message address to AX
	movw %ax, %bp				# Set BP to message address
	movw $0x01301, %ax		# BIOS teletype function
	movw $0x0c, %bx			# Attribute (red text)
	movw $21 ,%cx				# Message length
	movb $0, %dl				# Page number
	int $0x010				# BIOS video interrupt

	jmpl $SETUPSEG, $0		# Jump to setup code
msg:
	.ascii "Setup has been loaded"	# Boot message
