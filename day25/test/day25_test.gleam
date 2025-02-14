import day25.{part1}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  "5764801
17807724"
  |> part1
  |> should.equal(14_897_079)
}
