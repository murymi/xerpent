#!/bin/bash
# Simple assemble/link script.

if [ -z $1 ]; then
    echo "Usage: ./asm64 <asmMainFile> (no extension)"
    exit
fi
# Verify no extensions were entered
if [ ! -e "$1.asm" ]; then
    echo "Error, $1.asm not found."
    echo "Note, do not enter file extensions."
    exit
fi
# Compile, assemble, and link.
# -Worphan-labels  
yasm -g dwarf2 -f elf64 $1.asm -l $1.lst
ld -g -o $1 $1.o -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -lraylib -lm
# -no-pie 