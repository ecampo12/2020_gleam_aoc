import day05.{part1}
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  let inputs = ["FBFBBFFRLR", "BFFFBBFRRR", "FFFBBBFRRR", "BBFFBBFRLL"]
  let expected = [357, 567, 119, 820]
  list.zip(inputs, expected)
  |> list.map(fn(x) {
    let #(input, expected) = x
    part1(input) |> should.equal(expected)
  })
}
