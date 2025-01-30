import day09.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  "35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576"
  |> part1(5)
  |> should.equal(127)
}

pub fn part2_test() {
  "35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576"
  |> part2(5)
  |> should.equal(62)
}
