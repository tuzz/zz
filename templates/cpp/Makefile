CC := g++ -std=c++11 -Wall -Wextra -Werror -I src -I vendor

SOURCE := $(shell find src -name *.cpp)
TESTS  := $(shell find test -name *_test.cpp)

.PHONY: FORCE default clean

default: test bin/debug bin/release

test: bin/test
	$<

bin/test: build/test_runner.o FORCE
	$(CC) $< $(TESTS) -o $@

bin/debug: src/{name}.cpp $(SOURCE)
	$(CC) -g $< -o $@

bin/release: src/{name}.cpp $(SOURCE)
	$(CC) -O3 $< -o $@

build/test_runner.o: test/test_runner.cpp
	$(CC) -c $< -o $@

clean:
	rm -rf bin/* build/*
