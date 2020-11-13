#include <sys/regdef.h>
#include <sys/syscall.h>

	.text
	.abicalls
	.align 2
	.globl string_hash_more
	.ent string_hash_more

string_hash_more:

	.frame fp, 48, ra
	.set  noreorder
	.cpload t9
	.set reorder

	#stack frame
	subu sp, sp, 48
	.cprestore 32
	sw fp, 36(sp)
	sw ra, 40(sp)
	move fp, sp

	#salvo  argumento
	sw a0, 48(fp) #sh
	sw a1, 52(fp) #str
	sh a2, 56(fp) #len

	#armo struct
	lb t0, 0(a0) #flag
	lw t1, 4(a0) #hash
	lw t2, 8(a0) #size

	subu t3, t0, 1
	beq t3, zero, resuelvo_if 
	b while

resuelvo_if:
	
	#sh->flag = STRING_HASH_MORE;
	addiu t0, zero, 2 #sh->flag = 2
	sb t0, 0(a0) #actualizo sh->flag

	#sh->hash = (*str) << 7;
	lw t2, 52(fp)	#desreferencio str
	lb t2, 0(t2)	#levanto el primer byte
	sll t1, t2, 7
	sw t1, 4(a0) #acualizo hash directo en la memoria

while:	
	
	lw	t0, 52(fp)	# desreferencio str
	lb	t2, 0(t0)	#levanto el primer byte
	beq	t2, zero, salir
	beq	a2, zero, salir
	
	# Se cumplen ambas condiciones,cuerpo del while:

	lw t1, 4(a0) #traigo sh->hash
	mul	t1, t1, 1000003 #(1000003 * sh->hash)
	xor t1, t1, t2
	sw t1, 4(a0) #actualizo hash
	lw t0, 52(fp)
	addiu t0, t0, 1 #str++
	sw t0, 52(fp) #actualizo str

	lw t2, 8(a0) #traigo sh->size
	addiu	t2, t2, 1 #size++
	sw t2, 8(a0) #actualizo sh->size
	
	addiu t1, zero, 1 #t1 = 1
	subu a2, a2, t1 #len--
	sw a2, 56(fp)

	b while

salir:
	# (esta función no devuelve nada)
	lw	fp, 36(sp)
	addiu	sp, sp, 48
	jr	ra
	
	.end string_hash_more
