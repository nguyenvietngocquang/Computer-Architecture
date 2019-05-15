.data 
	mes: .asciiz "Nhap vao chuoi ky tu : " 
	d1: .space 4
	d2: .space 4
	d3: .space 4
	str: .space 1000
	array: .space 32
	error_length: .asciiz "Do dai chuoi khong hop le! Nhap lai!\n"
	comma: .asciiz ","
	enter: .asciiz "\n"
	hex: .byte '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' 
	m1: .asciiz "      Disk 1                 Disk 2               Disk 3\n"
	m2: .asciiz "----------------       ----------------       ----------------\n"
	m3: .asciiz "|     "
	m4: .asciiz "     |       "
	m5: .asciiz "[[ "
	m6: .asciiz "]]       "
	try: .asciiz "Try again?"
	
.text 
	la $s1, d1
	la $s2, d2
	la $s3, d3
	la $a2, array		# dia chi mang chua parity
	
input: 
	li $v0, 4	
	la $a0, mes
	syscall
	li $v0, 8	#Nhap vao xau
	la $a0, str
	li $a1, 1000
	syscall
	move $s0, $a0
	
#Kiem tra do dai xau chia het cho 8
length: 
	addi $t0, $zero, 0	# t0 = length
	addi $t1, $zero, 0	# t1 = index

checkText:
	add $t2, $s0, $t1	#dia chi cua str[i]
	lb $t3, 0($t2)		#str[i]
	nop
	beq $t3, 10, testLength	#gap ki tu xuong dong "\n"
	nop
	add $t0, $t0, 1		#length++
	add $t1, $t1, 1		#index++
	j checkText
	nop
	
testLength:
	move $t4, $t0
	and $t2, $t0, 0x0000000f#xoa tat ca cac byte cua $t0 ve  0, chi du lai byte cuoi
	bne $t2, 0, check8	#kiem tra byte cuoi bang 0 hoac bang 8
	j head

check8: 
	beq $t2, 8, head
	j errorLength
	
errorLength:
	li $v0, 4
	la $a0, error_length
	syscall
	j input
	
#Chuong trinh con lay ma hexa (parity)
parity: 
	li $t9, 7
	
loopParity: 
	blt $t9, $0, endParity
	sll $s7, $t9, 2		#s7 = t5*4
	srlv $a0, $t8, $s7	
	andi $a0, $a0, 0x0000000f	#lay byte cuoi cua a0
	la $t7, hex
	add $t7, $t7, $a0
	bgt $t9, 1, nextChar
	lb $a0, 0($t7)		
	li $v0, 11
	syscall

nextChar:
	add $t9, $t9, -1
	j loopParity
	
endParity:
	jr $ra
	
#Chuong trinh chinh
head:	li $v0, 4
	la $a0, m1
	syscall
	li $v0, 4
	la $a0, m2
	syscall
#Khoi thu nhat
part1:
	addi $t1, $zero, 0
	addi $t5, $zero, 0
	addi $t8, $zero, 0
	la $s1, d1
	la $s2, d2
	la $a2, array	
p11:
	lb $t2, ($s0)
	addi $t0, $t0, -1
	sb $t2, ($s1)	
p12:
	addi $s4, $s0, 4
	lb $t3, ($s4)
	addi $t0, $t0, -1
	sb $t3, ($s2)	
p13:
	xor $a3, $t2, $t3
	sw $a3, ($a2)
	addi $a2, $a2, 4
	addi $t1, $t1, 1
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	addi $s2, $s2, 1
	bgt $t1, 3, reset1
	j p11
reset1: 
	la $s1, d1
	la $s2, d2
	
print11:
	li $v0, 4
	la $a0, m3
	syscall
print12:
	lb $a0, ($s1)
	li $v0, 11
	syscall
	addi $t5, $t5, 1
	addi $s1, $s1, 1
	bgt $t5, 3, mid11
	j print12
mid11:
	li $v0, 4
	la $a0, m4
	syscall
	li $v0, 4
	la $a0, m3
	syscall
print13:
	lb $a0, ($s2)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $s2, $s2, 1
	bgt $t8, 3, mid12
	j print13
mid12:
	li $v0, 4
	la $a0, m4
	syscall
	li $v0, 4
	la $a0, m5
	syscall
	la $a2, array
	addi $t5, $zero, 0
print14:
	lb $t8, ($a2)
	jal parity
	li $v0, 4
	la $a0, comma
	syscall
	addi $t5, $t5, 1
	addi $a2, $a2, 4
	bgt $t5, 2, end1	# in ra 3 parity dau co dau ",", parity cuoi cung k co
	j print14
end1:	
	lb $t8, ($a2)
	jal parity
	li $v0, 4
	la $a0, m6
	syscall
	li $v0, 4
	la $a0, enter
	syscall
	beq $t0, 0, exit1	
#----------------------
part2:
	la $s1, d1
	la $s3, d3
	la $a2, array
	addi $s0, $s0, 4
	addi $t1, $zero, 0
p21:
	lb $t2, ($s0)
	addi $t0, $t0, -1
	sb $t2, ($s1)	
p23:
	addi $s4, $s0, 4
	lb $t3, ($s4)
	addi $t0, $t0, -1
	sb $t3, ($s3)	
p22:
	xor $a3, $t2, $t3
	sw $a3, ($a2)
	addi $a2, $a2, 4
	addi $t1, $t1, 1
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	addi $s3, $s3, 1
	bgt $t1, 3, reset2
	j p21
reset2: 
	la $s1, d1
	la $s3, d3
	addi $t5, $zero, 0
print21:
	li $v0, 4
	la $a0, m3
	syscall
print22:
	lb $a0, ($s1)
	li $v0, 11
	syscall
	addi $t5, $t5, 1
	addi $s1, $s1, 1
	bgt $t5, 3, mid21
	j print22
mid21:	
	li $v0, 4
	la $a0, m4
	syscall
	la $a2, array
	addi $t5, $zero, 0
	li $v0, 4
	la $a0, m5
	syscall
print23:
	lb $t8, ($a2)
	jal parity
	li $v0, 4
	la $a0, comma
	syscall
	addi $t5, $t5, 1
	addi $a2, $a2, 4
	bgt $t5, 2, mid22
	j print23		
mid22:	
	lb $t8, ($a2)
	jal parity
	li $v0, 4
	la $a0, m6
	syscall
	li $v0, 4
	la $a0, m3
	syscall
	addi $t8, $zero, 0
print24:
	lb $a0, ($s3)
	li $v0, 11
	syscall
	addi $t8, $t8, 1
	addi $s3, $s3, 1
	bgt $t8, 3, end2
	j print24
end2:	
	li $v0, 4
	la $a0, m4
	syscall
	li $v0, 4
	la $a0, enter
	syscall
	beq $t0, 0, exit1
#-----------------------
part3:
	la $a2, array
	la $s2, d2
	la $s3, d3
	addi $s0, $s0, 4
	addi $t1, $zero, 0
p32:
	lb $t2, ($s0)
	addi $t0, $t0, -1
	sb $t2, ($s2)	
p33:
	addi $s4, $s0, 4
	lb $t3, ($s4)
	addi $t0, $t0, -1
	sb $t3, ($s3)	
p31:
	xor $a3, $t2, $t3
	sw $a3, ($a2)
	addi $a2, $a2, 4
	addi $t1, $t1, 1
	addi $s0, $s0, 1
	addi $s2, $s2, 1
	addi $s3, $s3, 1
	bgt $t1, 3, reset3
	j p32
reset3:	
	la $s2, d2
	la $s3, d3
	la $a2, array
	addi $t5, $zero, 0
print31:
	li $v0, 4
	la $a0, m5
	syscall
print32:
	lb $t8, ($a2)
	jal parity
	li $v0, 4
	la $a0, comma
	syscall
	addi $t5, $t5, 1
	addi $a2, $a2, 4
	bgt $t5, 2, mid31
	j print32		
mid31:	
	lb $t8, ($a2)
	jal parity
	li $v0, 4
	la $a0, m6
	syscall
	li $v0, 4
	la $a0, m3
	syscall
	addi $t5, $zero, 0
print33:
	lb $a0, ($s2)
	li $v0, 11
	syscall
	addi $t5, $t5, 1
	addi $s2, $s2, 1
	bgt $t5, 3, mid32
	j print33
mid32:	
	addi $t5, $zero, 0
	li $v0, 4
	la $a0, m4
	syscall	
	li $v0, 4
	la $a0, m3
	syscall	
print34:
	lb $a0, ($s3)
	li $v0, 11
	syscall
	addi $t5, $t5, 1
	addi $s3, $s3, 1
	bgt $t5, 3, end3
	j print34

end3:	li $v0, 4
	la $a0, m4
	syscall
	li $v0, 4
	la $a0, enter
	syscall
	beq $t0, 0, exit1
#----------het 6 khoi dau-------
#----6 khoi tiep theo-----
nextPart:
	addi $s0, $s0, 4
	j part1
exit1:	
	li $v0, 4
	la $a0, m2
	syscall
	j ask
#--------try again-----------
ask:	
	li $v0, 50
	la $a0, try
	syscall
	beq $a0, 0, clear
	nop
	j exit
	nop
# dua string ve trang thai ban dau de thuc hien lai qua trinh
clear:	la $s0, str
	add $s3, $s0, $t4	# s3: dia chi byte cuoi cung duoc su dung trong string
	li $t2, 0
goAgain: 
	sb $t2, ($s0)		# set byte o dia chi s0 thanh 0
	nop
	addi $s0, $s0, 1
	bge $s0, $s3, input
	nop
	j goAgain
	nop
#--------end---------

exit:	li $v0, 10
	syscall
