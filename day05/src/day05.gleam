import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

// Turns out the input will just give us the ids once we replace some letters.
// No need for parsing and doing a binary search for each input.
fn to_seat_id(input: String) -> List(Int) {
  string.split(input, "\n")
  |> list.map(fn(x) {
    let assert Ok(id) =
      string.replace(x, "F", "0")
      |> string.replace("B", "1")
      |> string.replace("L", "0")
      |> string.replace("R", "1")
      |> int.base_parse(2)
    id
  })
  |> list.sort(int.compare)
}

pub fn part1(input: String) -> Int {
  let ids = to_seat_id(input)
  let assert Ok(highest) = list.last(ids)
  highest
}

pub fn part2(input: String) -> Int {
  let ids =
    to_seat_id(input) |> list.index_map(fn(x, i) { #(i, x) }) |> dict.from_list
  list.range(0, dict.size(ids))
  |> list.fold_until(0, fn(acc, x) {
    let assert Ok(id) = dict.get(ids, x)
    let assert Ok(next) = dict.get(ids, x + 1)
    case next - id != 1 {
      True -> list.Stop(id + 1)
      False -> list.Continue(acc)
    }
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
