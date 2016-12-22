#!/usr/bin/env bash

rm puzzle23.c
rm a.out
./puzzle23.rb > puzzle23.c
gcc puzzle23.c
./a.out
