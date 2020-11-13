CFLAGS=-Wall -g

all: clean tp1

tp1:
	$(CC) $(CFLAGS) -o tp1 myassert.S hashmore.S hash.c tp1.c

regressions:
	$(CC) $(CFLAGS) -o regressions regressions.c hash.c hashmore.S

test: regressions
	./regressions
	
clean:
	rm -f tp1 regressions

