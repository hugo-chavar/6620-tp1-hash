#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>

#include "hash.h"

typedef struct {
	int32_t hash;
	char *msg;
} regression;

int32_t
get_hash_(string_hash *sh, char *msg, size_t len, size_t stride)
{
	char *ptr = msg;
	size_t delta;
	size_t rem;

	string_hash_init(sh);
	for (rem = len; rem > 0; ) {
		if (rem >= stride)
			delta = stride;
		else
			delta = rem;
	
		string_hash_more(sh, ptr, delta);
		rem -= delta;
		ptr += delta;
	}
	string_hash_done(sh);

	return string_hash_value(sh);
}

int
get_hash(char *msg)
{
	size_t len = strlen(msg);
	size_t stride;
	string_hash sh;
	int32_t h0;
	int32_t h;

	if (len > 1) {
		h0 = get_hash_(&sh, msg, len, len);

		for (stride = len; stride >= 1; stride--) {
			h = get_hash_(&sh, msg, len, stride);
			assert(h0 == h);
		}
	}

	return h0;
}

int
main(int argc, char * const argv[])
{
	regression regressions[] = {
		{ 0xcc2b6c5a, "66.20 Organizacion de Computadoras\n" },
		{ 0xcb5af1f1, "TP 1 - Segundo Cuatrimestre, 2020\n"  },
		{ 0xcb5af1f1, "\n"                                   },
		{ 0xd788c5a5, "Archivo de prueba TP 1.\n"            },
		{ 0x91ff4b5b, "1\n"                                  },
		{ -1, NULL                                           },
	};
	regression *iter;
	int32_t hash;

	for (iter = regressions; iter->msg != NULL; iter++) {
	       hash = get_hash(iter->msg);
	       printf("0x%08x %s", hash, iter->msg);
	       assert(iter->hash == hash);
	}

	return 0;
}
