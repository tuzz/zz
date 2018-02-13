#include "catch.hpp"
#include "{name}/base.cpp"

TEST_CASE("{Name}") {
  {Name} *subject = new {Name}();

  SECTION("hello") {
    REQUIRE(subject->hello() == "Hello, world!");
  }
}
