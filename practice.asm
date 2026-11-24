.data
msg1: .asciiz"Enter first Number \n"
msg2: .asciiz"Enter second Number \n"
msg3: .asciiz"The Result is \t"

.text
.globl main
main:

    li $v0,4
    la $a0,msg1
    syscall


    li $v0,5
    syscall
    move $t0,$v0

    li $v0,4
    la $a0,msg2
    syscall


    li $v0,5 
    syscall
    move $t1,$v0

    mul $t3,$t1,$t0

    li $v0, 4
    la $a0,msg3
    syscall

    li $v0,1
    move $a0,$t3
    syscall


    li $v0,10
    syscall