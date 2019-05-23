# Mars Bot
.eqv HEADING 0xffff8010
.eqv LEAVETRACK 0xffff8020
.eqv WHEREX 0xffff8030
.eqv WHEREY 0xffff8040
.eqv MOVING 0xffff8050
# Key Matrix
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xffff0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xffff0014

.data
# (rotate, time, 0=untrack | 1=track);
# Numpad 0 => postscript-DCE
script1: .asciiz "90,3000,0;180,3000,0;180,11270,1;70,2000,1;50,2000,1;30,2000,1;10,2000,1;350,2000,1;330,2000,1;310,2000,1;290,2000,1;90,11000,0;250,2000,1;230,2000,1;210,2000,1;190,2000,1;170,2000,1;150,2000,1;130,2000,1;110,2000,1;90,8000,0;270,5000,1;0,11200,1;90,5000,1;270,5000,0;180,5600,0;90,5000,1;90,2000,0;"
# Numpad 4 => postscript-QUANG
script2: .asciiz "90,4000,0;180,2000,0;250,1000,1;230,1000,1;210,1000,1;190,1000,1;170,1000,1;150,1000,1;130,1000,1;110,1000,1;90,500,1;70,1000,1;50,1000,1;30,1000,1;10,1000,1;350,1000,1;330,1000,1;310,1000,1;290,1000,1;270,500,1;180,4000,0;90,1000,0;135,2100,1;90,1500,0;0,5300,0;180,4000,1;150,1000,1;120,1000,1;90,500,1;60,1000,1;30,1000,1;0,4000,1;90,3000,0;200,5400,1;20,2700,0;90,1900,1;340,2700,0;160,5400,1;90,1500,0;0,5200,1;150,5900,1;0,5200,1;90,4000,0;110,1000,0;290,1000,1;270,500,1;250,1000,1;230,1000,1;210,1000,1;190,1000,1;170,1000,1;150,1000,1;130,1000,1;110,1000,1;90,500,1;70,1000,1;0,2000,1;270,1000,0;90,2000,1;90,1000,0;"
# Numpad 8 => postscript-HUNG
script3: .asciiz "90,3000,0;180,3000,0;180,5300,1;0,2700,0;90,3000,1;0,2600,0;180,5300,1;90,1500,0;0,5300,0;180,4000,1;150,1000,1;120,1000,1;90,500,1;60,1000,1;30,1000,1;0,4000,1;90,1500,0;180,5200,1;0,5200,0;150,5900,1;0,5200,1;90,4000,0;110,1000,0;290,1000,1;270,500,1;250,1000,1;230,1000,1;210,1000,1;190,1000,1;170,1000,1;150,1000,1;130,1000,1;110,1000,1;90,500,1;70,1000,1;0,2000,1;270,1000,0;90,2000,1;90,1000,0;"

.text
# < Xu ly tren Key Matrix >
	li $t3, IN_ADDRESS_HEXA_KEYBOARD
	li $t4, OUT_ADDRESS_HEXA_KEYBOARD
	addi $t8, $zero, 0
	addi $t9, $zero, 0
polling:
	li $t5, 0x01 # Hang 1 cua Key matrix
	sb $t5, 0($t3)
	lb $a0, 0($t4)
	bne $a0, 0x11, NOT_NUMPAD_0 # Button 0 gia tri 0x11
	la $a1, script1
	j START
	NOT_NUMPAD_0:
	li $t5, 0x02 # Hang 2 cua Key matrix
	sb $t5, 0($t3)
	lb $a0, 0($t4)
	bne $a0, 0x12, NOT_NUMPAD_4 # Button 8 gia tri 0x12
	la $a1, script2
	j START
	NOT_NUMPAD_4:
	li $t5, 0x04 # Hang 3 cua Key matrix
	sb $t5, 0($t3)
	lb $a0, 0($t4)
	bne $a0, 0x14, COME_BACK # Button 8 gia tri 0x14
	la $a1, script3
	j START
COME_BACK: j polling # Khi 0, 4, 8 khong duoc chon -> Quay lai doc so tiep

# < Xu li Mars Bot >
START:
	jal GO
READ_SCRIPT:
	addi $t0, $zero, 0 # Luu gia tri rotate
	addi $t1, $zero, 0 # Luu gia tri time
	
 	READ_ROTATE:
 	add $t7, $a1, $t6 # Dich bit
	lb $t5, 0($t7)  # Doc cac ki tu cua script
	beq $t5, 0, CHECK_AGAIN # Ket thuc script khi gap null
 	beq $t5, 44, READ_TIME # Gap ki tu ','
 	mul $t0, $t0, 10
 	addi $t5, $t5, -48 # So 0 co thu tu 48 trong bang ASCII
 	add $t0, $t0, $t5  # Cong cac chu so lai voi nhau
 	addi $t6, $t6, 1 # Tang so bit can dich chuyen len 1
 	j READ_ROTATE # Quay lai doc tiep den khi gap dau ','
 	
 	READ_TIME:
 	add $a0, $t0, $zero
	jal ROTATE
 	addi $t6, $t6, 1
 	add $t7, $a1, $t6 # $a1 luu dia chi cua script
	lb $t5, 0($t7)
	beq $t5, 44, READ_TRACK
	mul $t1, $t1, 10
 	addi $t5, $t5, -48
 	add $t1, $t1, $t5
 	j READ_TIME # Quay lai doc tiep den khi gap dau ','
 	
 	READ_TRACK:
 	addi $v0, $zero, 32 # Cho Mars Bot tiep tuc chay bang cach sleep
 	add $a0, $zero, $t1 # Thoi gian sleep $t1
 	addi $t6, $t6, 1
 	add $t7, $a1, $t6
	lb $t5, 0($t7)
 	addi $t5, $t5, -48
 	addi $t8, $t8, 1
 	bne $t8, 3, BEGIN
 	li $at, WHEREX
	lw $a3, 0($at)
	li $at, WHEREY
	lw $a2, 0($at)
BEGIN:
 	beq $t5, $zero, CHECK_UNTRACK # 0=untrack | 1=track
 	jal UNTRACK
	jal TRACK
	j INCREAMENT
	
CHECK_UNTRACK:
	jal UNTRACK
	
INCREAMENT:
	syscall
 	addi $t6, $t6, 2 # Bo qua dau ';'
 	j READ_SCRIPT

GO: 
 	li $at, MOVING
 	addi $k0, $zero, 1
 	sb $k0, 0($at)
 	jr $ra

STOP: 
	li $at, MOVING
 	sb $zero, 0($at)
 	jr $ra

TRACK: 
	li $at, LEAVETRACK
 	addi $k0, $zero, 1
	sb $k0, 0($at)
 	jr $ra

UNTRACK:
	li $at, LEAVETRACK
 	sb $zero, 0($at)
 	jr $ra

ROTATE: 
	li $at, HEADING
 	sw $a0, 0($at)
 	jr $ra
 	
CHECK_AGAIN:
	addi $t9, $t9, 1
	beq $t9, 2, END

Y:	li $at, HEADING
	sw $zero, 0($at)
	li $at, WHEREY
	lw $s0, 0($at)
	bne $s0, $a2, Y
	
X:	addi $s2, $zero, 270
	li $at, HEADING
	sw $s2, 0($at)
	li $at, WHEREX
	lw $s1, 0($at)
	bne $s1, $a3, X
	
	la $a1, script1
	addi $t6, $zero, 21
	j READ_SCRIPT

END:
	jal STOP
	li $v0, 10
	syscall
	j polling