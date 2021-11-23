#!/bin/bash

# sudo apt-get install nasm

nasm -felf64 kuznyechik.asm
gcc -m64 -no-pie kuznyechik.o -o kuznyechik
./kuznyechik || echo "Error code: $?"
