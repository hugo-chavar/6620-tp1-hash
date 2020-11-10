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
	.cprestore 24		# sería .cprestore 40?
	sw fp, 28(sp)
	sw ra, 32(sp)
	move sp, fp

	#salvo argumentos
	sw a0, 40(fp) #sh
	sw a1, 44(fp) #str
	sw a2, 48(fp) #len


	beq a0, 1, resuelvo_if #if (sh->flag == STRING_HASH_INIT)

resuelvo_if:
	
	lw t0, a0 #flag
	#sh->flag = STRING_HASH_MORE;
	addiu t0, zero, 2 #flag = 2
	sw t0, 20(fp) #lo guardo en LTA

	#sh->hash = (*str) << 7;
	addiu t0, a0, 4
	lw t1, t0 #hash
	sll t1, a1, 7
	sw t1, 16(fp) #lo guardo en LTA
