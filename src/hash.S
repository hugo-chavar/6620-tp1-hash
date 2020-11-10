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

	#if (sh->flag == STRING_HASH_INIT)
	subu t3, t0, 1
	beq t3, zero, resuelvo_if 

resuelvo_if:
	
	#sh->flag = STRING_HASH_MORE;
	addiu t0, zero, 2 #flag = 2
	sb t0, 16(fp) 

	#sh->hash = (*str) << 7;
	lw t2, 0(a1) #desreferencio str
	sll t1, t2, 7
	sw t1, 16(fp) #guardo sh->hash en LTA
	
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

#str ya esta en a1	
while:	lw	t0, 52(fp)	# traigo str
	lb	t0, 0(t0)	# desreferencio
	beq	t0, zero, salir
	lw	t1, 56(fp)	# traigo len	# ¿esta bien, entra len en t1?
	beq	t1, zero, salir
	#be a2, zero, salir -> esta linea en vez de las dos anteriores porq len lo tengo en a2 cuando salvo argumentos al principio
	
	# Se cumplen ambas condiciones, cuerpo del while:
	lw	t2, 48(fp)	# traigo sh
	#como tengo guardado sh->hash en LTA deberiamos hacer asi:
	#lw t2, 16(fp)
	lw	t2, 1(t2)	# piso t2 con sh->hash, offset de 1 byte
	mul	t2, t2, 1000003

	#sh->hash = (1000003 * sh->hash) ^ *str++;
	addiu t0, t0, 1 #str++
	xor t2, t2, t0
	sw t2, 16(fp) #lo guardo en LTA

	lw	t3, 48(fp)	# traigo sh
	lw	t3, 5(t3)	# piso t3 con sh->size, offset de 1+4 bytes	#¿entre sieze en t3?
	addiu	t3, t3, 1
	#sw	t3, ...... #lo tengo que guardar donde estaba, pero estaba "adentro" del struct. Dónde lo guardo...?
	
	b while

salir:
	# (esta función no devuelve nada)
	lw	fp, 36(sp)
	addiu	sp, sp, 48
	jr	ra
	
	.end string_hash_more
