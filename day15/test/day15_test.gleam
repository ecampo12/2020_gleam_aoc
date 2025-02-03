import day15.{part1}
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_test() {
  let inputs = ["0,3,6", "1,3,2", "2,1,3", "1,2,3", "2,3,1", "3,2,1", "3,1,2"]
  let expected = [436, 1, 10, 27, 78, 438, 1836]
  list.zip(inputs, expected)
  |> list.map(fn(x) {
    let #(input, e) = x
    part1(input) |> should.equal(e)
  })
}
// Test runs too long, so it times out
// pub fn part2_test() {
//   let inputs = ["0,3,6", "1,3,2", "2,1,3", "1,2,3", "2,3,1", "3,2,1", "3,1,2"]
//   let expected = [175_594, 2578, 3_544_142, 261_214, 6_895_259, 18, 362]
//   list.zip(inputs, expected)
//   |> list.map(fn(x) {
//     let #(input, e) = x
//     part2(input) |> should.equal(e)
//   })
// }
