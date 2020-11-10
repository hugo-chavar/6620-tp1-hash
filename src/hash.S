#include <sys/regdef.h>
#include <sys/syscall.h>

	.text
	.abicalls
	.align 2
	.globl string_hash_more
	.ent string_hash_more

string_hash_more:

	.frame fp, 40, ra
	.set  noreorder
	.cpload t9
	.set reorder

#parece que las constantes se definen asi (chequearlo)
#STRING_HASH_INIT = 1
#STRING_HASH_MORE 2
#STRING_HASH_DONE 3

	#stack frame
	subu sp, sp, 40
	.cprestore 24
	sw fp, 28(sp)
	sw ra, 32(sp)
	move sp, fp

	#salvo argumentos
	sw a0, 40(fp) #sh
	sw a1, 44(fp) #str
	sw a2, 48(fp) #len

	lw t0,0(a0) #desreferencio sh->flag
	beq t0, 1, resuelvo_if #if (sh->flag == STRING_HASH_INIT)

resuelvo_if:
	
	lw t0, 0(a0) #flag, creo que esta de mas ya lo hice en linea 34
	#sh->flag = STRING_HASH_MORE;
	addiu t0, zero, 2 #flag = 2
	sw t0, 20(fp) #lo guardo en LTA

	#sh->hash = (*str) << 7;
	addiu t0, a0, 4
	lw t1, 0(t0) #hash
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
while:	lw	t0, 44(fp)	# traigo str
	lb	t0, 0(t0)	# desreferencio
	beq	t0, zero, salir
	lw	t1, 48(fp)	# traigo len	# ¿esta bien, entra len en t1?
	beq	t1, zero, salir
	#be a2, zero, salir -> esta linea en vez de las dos anteriores porq len lo tengo en a2 cuando salvo argumentos al principio
	
	# Se cumplen ambas condiciones, cuerpo del while:
	lw	t2, 40(fp)	# traigo sh
	#como tengo guardado sh->hash en LTA deberiamos hacer asi:
	#lw t2, 16(fp)
	lw	t2, 1(t2)	# piso t2 con sh->hash, offset de 1 byte
	mul	t2, t2, 1000003

	#sh->hash = (1000003 * sh->hash) ^ *str++;
	addiu t0, t0, 1 #str++
	xor t2, t2, t0
	sw t2, 16(fp) #lo guardo en LTA

	lw	t3, 40(fp)	# traigo sh
	lw	t3, 5(t3)	# piso t3 con sh->size, offset de 1+4 bytes	#¿entre sieze en t3?
	addiu	t3, t3, 1
	#sw	t3, ...... #lo tengo que guardar donde estaba, pero estaba "adentro" del struct. Dónde lo guardo...?
	
	b while

salir:
	# (esta función no devuelve nada)
	lw	fp, 28(sp)
	addiu	sp, sp, 40
	jr	ra
	
	.end string_hash_more
