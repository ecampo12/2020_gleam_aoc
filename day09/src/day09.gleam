import gleam/deque.{type Deque}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile.{read}

fn possible_next(nums: Deque(Int)) -> Set(Int) {
  deque.to_list(nums)
  |> list.combination_pairs
  |> list.map(fn(p) { p.0 + p.1 })
  |> set.from_list
}

pub fn part1(input: String, preamble_len: Int) -> Int {
  let nums =
    string.split(input, "\n")
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
  let preamble = list.take(nums, preamble_len) |> deque.from_list
  let #(_, invalid) =
    list.drop(nums, preamble_len)
    |> list.fold_until(#(preamble, 0), fn(acc, x) {
      case possible_next(acc.0) |> set.contains(x) {
        False -> list.Stop(#(acc.0, x))
        True -> {
          let assert Ok(#(_, update)) = acc.0 |> deque.pop_front
          list.Continue(#(deque.push_back(update, x), 0))
        }
      }
    })
  invalid
}

pub fn part2(input: String, preamble_len: Int) -> Int {
  let nums =
    string.split(input, "\n")
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
  let target = part1(input, preamble_len)
  let set_range =
    list.range(2, list.length(nums) - 1)
    |> list.fold_until([], fn(acc, x) {
      case list.find(list.window(nums, x), fn(a) { int.sum(a) == target }) {
        Ok(a) -> list.Stop(a)
        Error(_) -> list.Continue(acc)
      }
    })
    |> list.sort(int.compare)
  let smallest = list.first(set_range) |> result.unwrap(0)
  let largest = list.last(set_range) |> result.unwrap(0)
  smallest + largest
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input, 25)
  io.print("Part 1: ")
  io.debug(part1_ans)
  let part2_ans = part2(input, 25)
  io.print("Part 2: ")
  io.debug(part2_ans)
}
