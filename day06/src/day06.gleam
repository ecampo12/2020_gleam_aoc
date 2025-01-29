import gleam/io
import gleam/list
import gleam/set
import gleam/string
import simplifile.{read}

pub fn part1(input: String) -> Int {
  string.split(input, "\n\n")
  |> list.fold(0, fn(acc, group) {
    let questions =
      string.replace(group, "\n", "")
      |> string.to_graphemes
      |> list.unique
      |> list.length
    acc + questions
  })
}

pub fn part2(input: String) -> Int {
  string.split(input, "\n\n")
  |> list.fold(0, fn(acc, group) {
    let answers =
      string.split(group, "\n")
      |> list.map(fn(person) { string.to_graphemes(person) |> set.from_list })
    let assert Ok(first) = list.first(answers)
    let questions =
      list.fold(answers, first, fn(qcc, q) { set.intersection(q, qcc) })
      |> set.size
    acc + questions
  })
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  io.print("Part 1: ")
  io.debug(part1_ans)
  let part2_ans = part2(input)
  io.print("Part 2: ")
  io.debug(part2_ans)
}
