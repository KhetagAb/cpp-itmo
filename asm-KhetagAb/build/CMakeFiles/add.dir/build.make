# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.19

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Disable VCS-based implicit rules.
% : %,v


# Disable VCS-based implicit rules.
% : RCS/%


# Disable VCS-based implicit rules.
% : RCS/%,v


# Disable VCS-based implicit rules.
% : SCCS/s.%


# Disable VCS-based implicit rules.
% : s.%


.SUFFIXES: .hpux_make_needs_suffix_list


# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /mnt/c/Users/dzkhe/Desktop/C++/asm-KhetagAb

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /mnt/c/Users/dzkhe/Desktop/C++/asm-KhetagAb/build

# Include any dependencies generated for this target.
include CMakeFiles/add.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/add.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/add.dir/flags.make

CMakeFiles/add.dir/add.asm.o: CMakeFiles/add.dir/flags.make
CMakeFiles/add.dir/add.asm.o: ../add.asm
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/mnt/c/Users/dzkhe/Desktop/C++/asm-KhetagAb/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building ASM object CMakeFiles/add.dir/add.asm.o"
	nasm -f elf64 -g -F dwarf -o CMakeFiles/add.dir/add.asm.o /mnt/c/Users/dzkhe/Desktop/C++/asm-KhetagAb/add.asm

# Object files for target add
add_OBJECTS = \
"CMakeFiles/add.dir/add.asm.o"

# External object files for target add
add_EXTERNAL_OBJECTS =

add: CMakeFiles/add.dir/add.asm.o
add: CMakeFiles/add.dir/build.make
add: CMakeFiles/add.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/mnt/c/Users/dzkhe/Desktop/C++/asm-KhetagAb/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking ASM executable add"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/add.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/add.dir/build: add

.PHONY : CMakeFiles/add.dir/build

CMakeFiles/add.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/add.dir/cmake_clean.cmake
.PHONY : CMakeFiles/add.dir/clean

CMakeFiles/add.dir/depend:
	cd /mnt/c/Users/dzkhe/Desktop/C++/asm-KhetagAb/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /mnt/c/Users/dzkhe/Desktop/C++/asm-KhetagAb /mnt/c/Users/dzkhe/Desktop/C++/asm-KhetagAb /mnt/c/Users/dzkhe/Desktop/C++/asm-KhetagAb/build /mnt/c/Users/dzkhe/Desktop/C++/asm-KhetagAb/build /mnt/c/Users/dzkhe/Desktop/C++/asm-KhetagAb/build/CMakeFiles/add.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/add.dir/depend

