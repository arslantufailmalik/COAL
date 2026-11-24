.data
arr: .word 5, 12, 7, 3, 20, 9     
size: .word 6               
msg1: .asciiz "Aray elements:"
msg2: .asciiz "\nSum ="
space: .asciiz "  "

.text
.globl main
main:

    la $s0,arr
    lw $s1,size

    li $v0,4
    la $a0 ,msg1
    syscall

    li $t0, 0
    li $t2,0

loop:
    beq $t0,$s1,done
    
    sll $t1,$t0,2
    add $t1, $s0,$t1
    lw $t3,0($t1)

    add $t2,$t2,$t3

    li $v0,1
    move $a0,$t3
    syscall

    li $v0,4
    la $a0, space
    syscall

    addi $t0,$t0,1

    j loop

done:
    li $v0,4
    la $a0,msg2
    syscall

    li $v0,1
    move $a0,$t2
    syscall

    li $v0,10
    syscall
