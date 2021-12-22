# The target executable filename should correspond to a C++ source
# file that has a public main function with proper signature, sans the
# 'cc' file extension.  Otherwise, the implicit rules won't build it.
# In the case of our sample project, it is main.cc that contains
# the main function. Thus our executable should be named 'main'.
# We introduce a variable, executable_file, to hold this name, because
# it is referred to multiple times, and we try to follow the DRY principle.
source_file_with_main_function := main.cc

# Use substitution reference to remove the .cc file extension
# https://www.gnu.org/software/make/manual/make.html#Substitution-Refs
executable_file := $(source_file_with_main_function:.cc=)

# GNU Make has debug, info, and error "control functions"
# https://www.gnu.org/software/make/manual/html_node/Make-Control-Functions.html
# https://stackoverflow.com/a/16489377
# Here's an example of using info:
$(info The executable file is $(executable_file))

# Use the C++ linker
# https://lists.gnu.org/archive/html/help-make/2012-01/msg00058.html
# https://stackoverflow.com/a/13375395
# https://stackoverflow.com/a/29936672
# https://stackoverflow.com/a/33665503
# The problem is that both C and C++ source files compile to object files
# having the same file extension, `.o`. So how is make to know to use the
# C++ linker for linking these .o files into the final executable? (Apparently,
# the C linker can be used as well, the (only?) difference being that the C++
# linker includes the C++ standard library, which is almost always needed in
# any C++ program.) There are many solutions offered in the above discussions.
# The following solution is most in alignment with the default rules and
# variables. The default linker recipe invokes the linker defined in variable
# `LINK.o`.
#
# %: %.o
#       $(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@
#
# (Invoke: `make -p` to see default rules, recipes, and variables)
#
# LINK.o uses the C compiler, but, since this is a C++ project, it would
# be better to use the C++ compiler, for reasons including the fact that
# doing so will include the C++ standard library, which is needed by almost
# any C++ project.
#
# Fortunately, an another default variable, `LINK.cc`, is defined, which
# uses the C++ compiler. To use it in the default linker recipe,
# we need to redefine LINK.o to have the value of LINK.cc.

LINK.o := $(LINK.cc)

# LINK.cpp aliases LINK.cc, so use that if you prefer.
#
# Aside: .cpp vs .cc
# Different communities prefer different file extension for C++ files.
# The .cpp extension is believed to have started at Microsoft.
# It seems the .cc extension is more popular in Unix culture.
# https://www.quora.com/Why-do-both-cc-and-cpp-file-extensions-exist-for-C-Whats-the-history-behind-this
# https://stackoverflow.com/q/18590135
# https://retrocomputing.stackexchange.com/q/20281
# Google C++ Style Guide uses .cc file extension
# https://google.github.io/styleguide/cppguide.html#File_Names
# I like that because then CPP always means C Pre Processor, as in CPPFLAGS.

# C preprocessor flags for automatic dependency rule generation
# for included files
# https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html
# https://stackoverflow.com/a/12857539
# https://bruno.defraine.net/techtips/makefile-auto-dependencies-with-gcc/
# http://www.microhowto.info/howto/automatically_generate_makefile_dependencies.html
# -MMD generate dependency files for included files,
#  but not for system header files
# -MP is recommended to workaround errors that would happen
#  if you remove header files
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
CXXFLAGS := -std=c++11 -Wpedantic -Wall -Wextra -g

SRC := $(wildcard *.cc)
OBJ := $(SRC:.cc=.o)
DEP := $(SRC:.cc=.d)

# The default goal is the target of the first rule in the makefile
# https://www.gnu.org/software/make/manual/html_node/Rules.html
$(executable_file): $(OBJ)

.PHONY: clean
clean:
	rm -f $(OBJ) $(DEP) $(executable_file)

# Putting a hyphen in front of the include directive quiesces warning messages when the .d files don't exist.
# https://clarkgrubb.com/makefile-style-guide
-include $(DEP)
