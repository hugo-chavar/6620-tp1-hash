#include <sys/regdef.h>
#include <sys/syscall.h>

	.text
	.abicalls
	.align 2
	.globl string_hash_more
	.ent string_hash_more

string_hash_more:

	.frame fp, 32, ra
	.set  noreorder
	.cpload t9
	.set reorder

	#stack frame
	subu	sp, sp, 32
	.cprestore 16
	sw	fp, 20(sp)
	sw	ra, 24(sp)
	move	fp, sp

	#salvo argumento
	sw	a0, 32(fp)	#sh
	sw	a1, 36(fp)	#str
	sw	a2, 40(fp)	#len

	#armo struct
	lb	t0, 0(a0)	#flag
	lw	t1, 4(a0)	#hash
	lw	t2, 8(a0)	#size

	# myassert
	addiu	t3, zero, 1
	addiu	t4, zero, 2
	
	sne	t5, t3, t0 # flag = STRING_HASH_INIT;
	sne	t6, t4, t0 # flag = STRING_HASH_MORE;
	or	a0, t5, t6
	la	t9, myassert
	jal	t9
	
	lw	a0, 32(fp)
	lb	t0, 0(a0)	#flag
	addiu	t3, zero, 1
	beq	t0, t3, resuelvo_if
	b	while

resuelvo_if:
	
	#sh->flag = STRING_HASH_MORE;
	addiu	t0, zero, 2	#sh->flag = 2
	lw	a0, 32(fp)
	sb	t0, 0(a0)	#actualizo sh->flag

	#sh->hash = (*str) << 7;
	lw	t2, 36(fp)	#desreferencio str
	lb	t2, 0(t2)	#levanto el primer byte
	sll	t1, t2, 7
	sw	t1, 4(a0)	#acualizo hash directo en la memoria

while:
	
	lw	t0, 36(fp)	# desreferencio str
	lb	t2, 0(t0)	#levanto el primer byte
	beq	t2, zero, salir
	lw	a2, 40(fp)
	beq	a2, zero, salir
	
	# Se cumplen ambas condiciones,cuerpo del while:

	lw	a0, 32(fp)
	lw	t1, 4(a0)	#traigo sh->hash
	mul	t1, t1, 1000003	#(1000003 * sh->hash)
	xor	t1, t1, t2 #^ *str++
	sw	t1, 4(a0)	#actualizo hash
	lw	t0, 36(fp)
	addiu	t0, t0, 1	#str++
	sw	t0, 36(fp)	#actualizo str

	lw	t2, 8(a0) #traigo sh->size
	addiu	t2, t2, 1 #size++
	sw	t2, 8(a0) #actualizo sh->size
	
	addiu	t1, zero, 1 
	subu	a2, a2, t1 #len--
	sw	a2, 40(fp)

	b	while

salir:
	# (esta función no devuelve nada)
	lw	fp, 20(sp)
	lw	ra, 24(sp)
	addiu	sp, sp, 32
	jr	ra
	
	.end string_hash_more
