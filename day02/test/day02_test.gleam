import day02.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc"

pub fn part1_test() {
  input
  |> part1
  |> should.equal(2)
}

pub fn part2_test() {
  input
  |> part2
  |> should.equal(1)
}
