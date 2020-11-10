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
	move sp, fp

	#salvo  argumento
	sw a0, 48(fp) #sh
	sw a1, 52(fp) #str
	sw a2, 56(fp) #len

	#armo struct
	lb t0, 0(a0) #flag
	sb t0, 16(fp) #lo guardo en LTA
	lw t1, 4(a0) #hash
	sw t1, 20(fp)
	lw t2, 8(a0) #size
	sw t2, 24(fp)

	subu t3, t0, 1
	beq t3, zero, resuelvo_if 

resuelvo_if:
	
	#sh->flag = STRING_HASH_MORE;
	addiu t0, zero, 2 #flag = 2
	sb t0, 16(fp) 

	#sh->hash = (*str) << 7;
	lw t3, 0(a1) #desreferencio str, piso valor de t3
	sll t1, t3, 7
	sw t1, 20(fp) #guardo sh->hash en LTA
	
###########

#while ((*str) != 0 && len--) {
#		sh->hash = (1000003 * sh->hash) ^ *str++;
#		sh->size++;
#	}

### IMPORTANTE: tomé los argumentos desde la SRA, donde se guardaron al principio, o sea que si el if los cambió
# yo estoy usando los valores sin cambiar, es decir que así como está no va a andar.
# Para traerlos desde LTA, sh->hash quedó en 16(fp), y sh->flag en 20(fp).
# Usábamos LTA en vez de sobreescribir SRA x la convención?

### Importante2: estoy usando demasiados temporales, ya sé, capaz me pasé de los 40 reservados, podría pisar t0 y seguir desde ahí.

while:	
	
	lw	t0, 0(a1)	# desreferencio str
	beq	t0, zero, salir
	addiu t1, zero, 1 #t1 = 1
	subu a2, a2, t1 #len--
	beq a2, zero, salir
	
	# Se cumplen ambas condiciones,cuerpo del while:

	lw t1, 20(fp) #traigo sh->hash
	mul	t1, t1, 1000003 #(1000003 * sh->hash)
	addiu t0, t0, 1 #str++
	xor t1, t1, t0
	sw t1, 20(fp)

	lw	t2, 24(fp)	# traigo sh->size
	addiu	t2, t2, 1 #size++
	sw t2, 24(fp)
	
	b while

salir:
	# (esta función no devuelve nada)
	lw	fp, 36(sp)
	addiu	sp, sp, 48
	jr	ra
	
	.end string_hash_more
