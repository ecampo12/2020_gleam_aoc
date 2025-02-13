import day23.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  "389125467" |> part1 |> should.equal("67384529")
}

// Still not sure what I need to change to increase the timeout for long tests
pub fn part2_test() {
  "389125467" |> part2 |> should.equal("149245887792")
}
