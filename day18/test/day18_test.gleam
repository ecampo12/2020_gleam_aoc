import day18.{part1, part2}
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  [
    #("1 + 2 * 3 + 4 * 5 + 6", 71),
    #("1 + (2 * 3) + (4 * (5 + 6))", 51),
    #("2 * 3 + (4 * 5)", 26),
    #("5 + (8 * 3 + 9 + 3 * 4 * 3)", 437),
    #("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))", 12_240),
    #("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2", 13_632),
  ]
  |> list.map(fn(x) {
    let #(i, e) = x
    part1(i)
    |> should.equal(e)
  })
}

pub fn part2_test() {
  [
    #("1 + 2 * 3 + 4 * 5 + 6", 231),
    #("1 + (2 * 3) + (4 * (5 + 6))", 51),
    #("2 * 3 + (4 * 5)", 46),
    #("5 + (8 * 3 + 9 + 3 * 4 * 3)", 1445),
    #("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))", 669_060),
    #("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2", 23_340),
  ]
  |> list.map(fn(x) {
    let #(i, e) = x
    part2(i)
    |> should.equal(e)
  })
}
