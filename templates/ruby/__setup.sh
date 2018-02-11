#!/bin/bash

rm __setup.sh

bundle

git init
git add -A
git commit -m "Initial commit"

bundle exec rake
