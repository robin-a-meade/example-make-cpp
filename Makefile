# The target executable file name must correspond to a C++ source
# file that has a public main method with proper signature, but without the
# 'cpp' file extension.  Otherwise, the implicit rules won't build it.
executable := main

# Use the C++ linker
# https://lists.gnu.org/archive/html/help-make/2012-01/msg00058.html
# https://stackoverflow.com/a/13375395
# https://stackoverflow.com/a/29936672
# https://stackoverflow.com/a/33665503
# This solution fits best with the default variables and rules:
LINK.o = $(LINK.cc)

# C preprocessor (CPP) flags for auto dependencies
# https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html
# https://stackoverflow.com/a/12857539
# https://bruno.defraine.net/techtips/makefile-auto-dependencies-with-gcc/
# http://www.microhowto.info/howto/automatically_generate_makefile_dependencies.html
# -MMD generate dependency files for included files, but not system header files
# -MP is recommended to workaround errors that would occur if you remove header
#  files # without updating the Makefile to match
CPPFLAGS += -MMD -MP

# You'll probably want to set some CXXFLAGS too.
# This variable is for extra flags to give to the C++ compiler. 
# https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html
# https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
# https://gcc.gnu.org/onlinedocs/gcc/Debugging-Options.html
# Perhaps add these flags:
#  -std=c++11  Use the C++11 standard
#  -Wpedantic  Turns on all the warnings demanded by strict ISO C++
#  -Wall       Turns on many warning flags
#  -Wextra     Turns on extra warning flags
#  -g          Produce debugging information
CXXFLAGS = -std=c++11 -Wpedantic -Wall -Wextra -g

SRC := $(wildcard *.cpp)
OBJ := $(SRC:.cpp=.o)
DEP := $(SRC:.cpp=.d)

# The default goal is the target of the first rule in the makefile
# https://www.gnu.org/software/make/manual/html_node/Rules.html
$(executable): $(OBJ)

.PHONY: clean
clean:
	rm -f $(OBJ) $(DEP) $(executable)

-include include $(DEP)
