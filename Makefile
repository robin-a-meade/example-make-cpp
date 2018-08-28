# Makefile for Separate Compilation Example

# *****************************************************
# Parameters to control Makefile operation

CXX = g++
CXXFLAGS = 

# ****************************************************
# Entries to bring the executable up to date

main: main.o Point.o Rectangle.o
	$(CXX) $(CXXFLAGS) -o main main.o Point.o Rectangle.o

main.o: Point.h Rectangle.h

Point.o: Point.h

Rectangle.o: Rectangle.h Point.h
