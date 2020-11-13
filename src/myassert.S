#include <sys/regdef.h>
#include <sys/syscall.h>

	
	.rdata

msg: .asciiz	"Assertion error (Assemby).\n"

	.text

	.abicalls
	.align	2
	.globl	myassert
	.ent	myassert
myassert:
	.frame	fp, 8, ra
	.set	noreorder
	.cpload t9
	.set reorder

	subu	sp, sp, 8
	.cprestore 0
	sw	fp, 4(sp)
	move	fp, sp
	
	sw	a0,8(fp)

	beq	a0, zero, myerr	# si argumento es falso => error
	b	fin	# sale ok
myerr:
	#hay que mostrar error y terminar el proceso
	li	a0, 2	# stderr
	la	a1, msg	# error a mostrar
	li	a2, 27	# longitud del mensaje 
	li	v0, SYS_write
	syscall

	#chequeo de error
	beq	a3, zero, salir
	li	v0, -1
	j	fin
	
salir:
	li	a0, 1
	li	v0, SYS_exit
	syscall
	

fin:
	move	sp,fp
	lw	fp,4(sp)
	addiu	sp,sp,8
	jr	ra

	.end myassert


