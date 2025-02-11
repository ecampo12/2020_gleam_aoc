import day22.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  "Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10"
  |> part1
  |> should.equal(306)
}

pub fn part2_test() {
  "Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10"
  |> part2
  |> should.equal(291)
}
