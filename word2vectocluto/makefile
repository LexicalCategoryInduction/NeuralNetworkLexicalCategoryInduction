CC = gcc

#Using -Ofast instead of -O3 might result in faster code, but is supported only by newer GCC versions
CFLAGS = -O3 -march=native -Wall -funroll-loops -Wno-unused-result

all: word2vectocluto 

word2vectocluto : word2vectocluto.c
	$(CC) word2vectocluto.c -o word2vectocluto $(CFLAGS)

clean:
	rm -rf word2vectocluto