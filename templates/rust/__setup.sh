#!/bin/bash

rm __setup.sh

cargo test
cargo bench

git init
git add -A
git commit -m "Initial commit"
