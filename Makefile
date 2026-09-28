# Variables del compilador
CC = gcc
CFLAGS = -Wall -Wextra -g -fPIC
LDFLAGS = -L. -Wl,-rpath=.

.PHONY: all clean

# Regla por defecto que compila todo
all: libclaves.so libproxyclaves.so servidor cliente

# 1. Creación de las bibliotecas dinámicas (.so)

# Biblioteca local (usada por el servidor)
libclaves.so: claves.o
	$(CC) -shared -o $@ $^ -lpthread

claves.o: claves.c claves.h
	$(CC) $(CFLAGS) -c $<

# Biblioteca proxy (usada por el cliente)
libproxyclaves.so: proxy-sock.o
	$(CC) -shared -o $@ $^

proxy-sock.o: proxy-sock.c claves.h
	$(CC) $(CFLAGS) -c $<

# 2. Creación de los ejecutables

# Ejecutable del servidor (enlaza con libclaves.so y pthreads)
servidor: servidor-sock.o libclaves.so
	$(CC) -o $@ servidor-sock.o $(LDFLAGS) -lclaves -lpthread

servidor-sock.o: servidor-sock.c claves.h
	$(CC) $(CFLAGS) -c $<

# Ejecutable del cliente (enlaza con libproxyclaves.so)
cliente: app-cliente.o libproxyclaves.so
	$(CC) -o $@ app-cliente.o $(LDFLAGS) -lproxyclaves

app-cliente.o: app-cliente.c claves.h
	$(CC) $(CFLAGS) -c $<

# 3. Limpieza de archivos generados
clean:
	rm -f *.o *.so servidor cliente