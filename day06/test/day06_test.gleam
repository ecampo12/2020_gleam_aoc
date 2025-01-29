import day06.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_one_group_test() {
  "abcx
abcy
abcz"
  |> part1
  |> should.equal(6)
}

pub fn part1_five_group_test() {
  "abc

a
b
c

ab
ac

a
a
a
a

b"
  |> part1
  |> should.equal(11)
}

pub fn part2_test() {
  "abc

a
b
c

ab
ac

a
a
a
a

b"
  |> part2
  |> should.equal(6)
}
