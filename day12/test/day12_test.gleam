import day12.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  "F10
N3
F7
R90
F11"
  |> part1
  |> should.equal(25)
}

pub fn part2_test() {
  todo
}
