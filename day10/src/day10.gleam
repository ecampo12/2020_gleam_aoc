import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile.{read}

pub fn part1(input: String) -> Int {
  let adapters =
    string.split(input, "\n")
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
    |> list.sort(int.compare)
  let last = list.last(adapters) |> result.unwrap(0)
  let count =
    list.zip([0, ..adapters], list.append(adapters, [last + 3]))
    |> list.fold(#(0, 0), fn(acc, x) {
      let #(a, b) = x
      case b - a == 1, b - a == 3 {
        True, _ -> #(acc.0 + 1, acc.1)
        _, True -> #(acc.0, acc.1 + 1)
        _, _ -> acc
      }
    })
  count.0 * count.1
}

pub fn part2(input: String) -> Int {
  let adapters =
    string.split(input, "\n")
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
    |> list.sort(int.compare)
  let last = list.last(adapters) |> result.unwrap(0)
  let nums = [last, ..adapters] |> set.from_list

  let counts =
    list.range(1, last + 1)
    |> list.fold(#(0, 0, 1), fn(acc, i) {
      case set.contains(nums, i) {
        True -> #(acc.1, acc.2, acc.0 + acc.1 + acc.2)
        False -> #(acc.1, acc.2, 0)
      }
    })
  counts.1
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
