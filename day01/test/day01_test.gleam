import day01.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "1721
979
366
299
675
1456"

pub fn part1_test() {
  input
  |> part1
  |> should.equal(514_579)
}

pub fn part2_test() {
  input
  |> part2
  |> should.equal(241_861_950)
}
