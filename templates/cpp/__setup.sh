#!/bin/bash

rm __setup.sh

make
./bin/release

git init
git add -A
git commit -m "Initial commit"
