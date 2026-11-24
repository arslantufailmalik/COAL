.data
msg: .asciiz "The Result is"
a: .word 5
a1: .word 7

.text
.globl main
main:

    lw $t0,a
    lw $t1, a1
    mul $t2 $t0, $t1

    li $v0 ,4   #syscall code for print string
    la $a0 ,msg
    syscall

    li $v0 ,1   #syscall code for print integer
    move $a0, $t2
    syscall

    li $v0,10
    syscall  