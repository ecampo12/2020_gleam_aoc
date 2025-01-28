import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

pub fn part1(input: String) -> Int {
  string.split(input, "\n")
  |> list.map(fn(x) {
    let assert Ok(n) = int.parse(x)
    n
  })
  |> list.combination_pairs
  |> list.fold_until(0, fn(acc, p) {
    let #(a, b) = p
    case a + b == 2020 {
      True -> list.Stop(a * b)
      False -> list.Continue(acc)
    }
  })
}

pub fn part2(input: String) -> Int {
  string.split(input, "\n")
  |> list.map(fn(x) {
    let assert Ok(n) = int.parse(x)
    n
  })
  |> list.combinations(3)
  |> list.fold_until(0, fn(acc, three) {
    case three {
      [a, b, c] ->
        case a + b + c == 2020 {
          True -> list.Stop(a * b * c)
          False -> list.Continue(acc)
        }
      _ -> list.Continue(acc)
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
