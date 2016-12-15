#!/usr/bin/env bash

args=("$@")
rm a.out
gcc ${args[0]}
./a.out
