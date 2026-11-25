.data
msg: .asciiz "counting from 1 to 10:"
space: .asciiz " "
done: .asciiz "\nLoop finished\n"

.text
.globl main

main:
        li $v0,4
        la0 $a0,msg
        syscall

        li $t0,1
        li $t1,10

loop:
        bgt $t0,$t1, end_loop
        
        li $v0,1
        move $a0,$t0
        syscall

        li $v0,4
        la $a0,space
        syscall

        addi $t0,$t0,1

        j loop

end_loop:
        li $v0,4
        la $a0,done
        syscall

        li $v0,10
        syscall