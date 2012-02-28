CC=gcc -Wall -Werror --std=c99 -pedantic -pedantic-errors
BIN=bin
SRC=src
OBJ=obj
INC=include

.PHONY: clean

all: ${BIN}/start

${OBJ}/machine.o: ${SRC}/machine.c ${INC}/machine.h
	${CC} -c -I ${INC} -o $@ $<

${OBJ}/start.o: ${SRC}/start.c
	${CC} -c -I ${INC} -o $@ $<

${BIN}/start: ${OBJ}/start.o ${OBJ}/machine.o
	${CC} -I ${INC} -o $@ $^

${BIN}/test: ${SRC}/test.c
	${CC} -I ${INC} -o $@ $<


clean:
	rm -f ${OBJ}/* ${BIN}/* ${SRC}/*~ ${INC}/*~ *~