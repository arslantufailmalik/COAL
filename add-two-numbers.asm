.data
msg: .asciiz "The result is:"
a: .word 5
a1: .word 7

.text
.globl main
main:
    lw $t0,a
    lw $t1, a1
    add $t2, $t0, $t1

    li $v0,4
    la $a0,msg
    syscall

    li $v0,1
    move $a0,$t2
    syscall

    li $v0,10
    syscall
