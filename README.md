# Makefile for basic C++ project, with automatic dependency rule generation for included files

## Makefile

```
# The target executable file name must correspond to a C++ source
# file that has a public main method with proper signature, but without the
# 'cpp' file extension.  Otherwise, the implicit rules won't build it.
executable := main

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
# variables. The default rules define a C++ linker rule in variable `LINK.cc`. 
# (Also aliased as `LINK.cpp`, if you prefer.) So use it:
LINK.o = $(LINK.cc)

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

-include $(DEP)
```

## Use the C++ Linker

The problem and possible solutions are described in the following links:

* https://lists.gnu.org/archive/html/help-make/2012-01/msg00058.html
* https://stackoverflow.com/a/13375395
* https://stackoverflow.com/a/29936672
* https://stackoverflow.com/a/33665503

The problem is that both C and C++ source files compile to object files having the same file extension, `.o`. So how is `make` to know to use the C++ linker for linking these `.o` files into the final executable? (Apparently, the C linker can be used as well, the (only?) difference being that the C++ linker includes the C++ standard library, which is almost always needed in any C++ program.) There are many solutions offered in the above discussions. The following solution is most in alignment with the default rules and variables. The default rules define a C++ linker rule in variable `LINK.cc`. (Also aliased as `LINK.cpp`, if you prefer.) So use it:

```
LINK.o = $(LINK.cc)
```

## Automatic dependency rule generation for included files

Naturally, a file depends on any files it includes. Take, for example, a C++ source file that includes header files:

main.cpp:
```
#include <iostream.h>
#include "Point.h"
#include "Rectangle.h"
...
```

To capture these dependency relationships, you'd need to add rules like:

```
main.o : main.cpp Point.h Rectangle.h
```

(Note we didn't include `iostream.h`. This's because that is a system header file, and, therefore, wouldn't be expected to change.)

Writing such rules is tedious and error prone. Fortunately, modern C and C++ compilers can write these rules 
for us by looking at the `#include` lines in the source files. That is what is meant by _Automatic dependency generation_.

What flags do we need to give the compiler to instruct it to create these rules, and in what variable should we put these flags?

### Research

Here's some excerpts showing how others have configured make for automatic dependency generation:

> The options `-MMD -MP` are a modern way of implementing [auto dependencies with GNU make].
<br>https://bruno.defraine.net/techtips/makefile-auto-dependencies-with-gcc/

> Because `-MD` and `-MP` are preprocessor options, the standard method for setting them 
within a makefile is to append them to `CPPFLAGS`:
> ```
>     CPPFLAGS += -MD -MP
> ```
> http://www.microhowto.info/howto/automatically_generate_makefile_dependencies.html

> **`-MMD`**<br>
> Like `-MD` except mention only user header files, not system header files. 
> <br>https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html

> ```
> %.o: %.c
>    $(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -o $@ -c $<
> -include $(SOURCES:.c=.d)
> ```
> https://stackoverflow.com/a/10700187

> ```
> CXXFLAGS += -MMD -MP
> -include $(OBJS:$(OBJ_EXT)=.d)
> ```
> https://stackoverflow.com/a/10456349

> ```
> CPPFLAGS += -MMD -MP
> ...
> -include $(OBJS:.o=.d)
> ```
> https://stackoverflow.com/a/12857539

### Conclusions

* The modern method of implementing automatic dependency rule generation for included files with GNU make is to use the `-MMD -MP` preprocessor options, and an include directive like:
 `-include $(OBJS:.o=.d)`. (The purpose of the initial hyphen is to suppress the error messages that would otherwise appear when the dependency files do not already exist.)
* The `-MMD -MP` options are preprocessor options, they, therefore, belong in the `CPPFLAGS` variable. (Not `CXXFLAGS` or `OUTPUT_OPTION` as you might see in some examples you find in the wild.)
* The older method used `-MM` or `-M` option in combination with `sed`. ([link1](http://scottmcpeak.com/autodepend/autodepend.html) ([via](http://bruno.defraine.net/techtips/makefile-auto-dependencies-with-gcc/)), [link2](https://www.gnu.org/software/make/manual/html_node/Automatic-Prerequisites.html))

## Aside: Difference between `CPPFLAGS` and `CXXFLAGS`

Sometimes CPP means C++, but in the case of CPPFLAGS, it means C PreProcessor.

<<<
CPPFLAGS is supposed to be for flags for the C PreProcessor; CXXFLAGS is for flags for the C++ compiler.

<<< [[https://stackoverflow.com/a/495646/1157557]]

## Tip: Show make's variables and rules
You can get make to print out its variables and rules database using the invocation `make -p`


## References
### Automatic rule generation for included files
http://bruno.defraine.net/techtips/makefile-auto-dependencies-with-gcc/<br>
http://www.microhowto.info/howto/automatically_generate_makefile_dependencies.html<br>
http://www.gnu.org/software/make/manual/html_node/Automatic-Prerequisites.html<br>
https://gcc.gnu.org/onlinedocs/gcc/Preprocessor-Options.html<br>
http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/<br>
https://felixcrux.com/blog/creating-basic-makefile<br>
http://stackoverflow.com/a/15857914<br>
https://stackoverflow.com/q/5229561<br>
http://scottmcpeak.com/autodepend/autodepend.html (predates -MMD -MP)<br>
http://www.drdobbs.com/dependency-management/184406479 (predates -MMD -MP)<br>
### Using the C++ linker
https://lists.gnu.org/archive/html/help-make/2012-01/msg00058.html<br>
https://stackoverflow.com/a/13375395<br>
https://stackoverflow.com/a/29936672<br>
https://stackoverflow.com/a/33665503<br>


