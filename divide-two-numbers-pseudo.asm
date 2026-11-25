.data
msg: .asciiz "The Result is"
a: .word 10
a1: .word 2

.text
.globl main
main:
    lw $t0 ,a
    lw $t1, a1
    div $t2,$t0,$t1

    li $v0,4  #print string
    la $a0,msg
    syscall

    li $v0, 1  #print integer
    move $a0,$t2
    syscall
     
    li $v0,10
    syscall