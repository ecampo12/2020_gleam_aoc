import day13.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  "939
7,13,x,x,59,x,31,19"
  |> part1
  |> should.equal(295)
}

pub fn part2_test() {
  "939
7,13,x,x,59,x,31,19"
  |> part2
  |> should.equal(1_068_781)
}

pub fn part2_example1_test() {
  "939
17,x,13,19"
  |> part2
  |> should.equal(3417)
}

pub fn part2_example2_test() {
  "939
67,7,59,61"
  |> part2
  |> should.equal(754_018)
}

pub fn part2_example3_test() {
  "939
67,x,7,59,61"
  |> part2
  |> should.equal(779_210)
}

pub fn part2_example4_test() {
  "939
67,7,x,59,61"
  |> part2
  |> should.equal(1_261_476)
}

pub fn part2_example5_test() {
  "939
1789,37,47,1889"
  |> part2
  |> should.equal(1_202_161_486)
}
