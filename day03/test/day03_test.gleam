import day03.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

const input = "..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#"

pub fn part1_test() {
  input |> part1 |> should.equal(7)
}

pub fn part2_test() {
  input |> part2 |> should.equal(336)
}
