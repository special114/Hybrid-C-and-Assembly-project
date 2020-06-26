CXX = g++ -m64 -Wall


all: Bezier

Bezier: main.o f.o
	$(CXX) main.o f.o -lglut -lGLU -lGL -o Bezier

main.o: main.cpp
	$(CXX) main.cpp -c -o main.o

f.o: f.s
	nasm -f elf64 -o f.o f.s

.PHONY: clean

clean:
	rm -rf *o Bezier
