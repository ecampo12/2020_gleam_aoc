import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

type Policy {
  Policy(min: Int, max: Int, given: String, password: String)
}

fn parse(input: String) -> List(Policy) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    case string.split(line, ": ") {
      [policy, password] ->
        case string.split(policy, " ") {
          [range, given] ->
            case string.split(range, "-") {
              [a, b] -> {
                let assert Ok(min) = int.parse(a)
                let assert Ok(max) = int.parse(b)
                Policy(min, max, given, password)
              }
              _ -> Policy(-1, -1, "", "")
            }
          _ -> Policy(-1, -1, "", "")
        }
      _ -> Policy(-1, -1, "", "")
    }
  })
}

pub fn part1(input: String) -> Int {
  parse(input)
  |> list.fold(0, fn(acc, policy) {
    let count =
      string.to_graphemes(policy.password)
      |> list.count(fn(x) { x == policy.given })
    case policy.min <= count && policy.max >= count {
      True -> acc + 1
      False -> acc
    }
  })
}

// I couls use glearray here instead of doing a linear search, 
// but I dont want to import a module for one bit of the puzzle
fn get(password: List(String), index: Int) -> String {
  list.index_fold(password, "", fn(acc, char, i) {
    case i == index {
      False -> acc
      True -> char
    }
  })
}

pub fn part2(input: String) -> Int {
  parse(input)
  |> list.fold(0, fn(acc, p) {
    let s = string.to_graphemes(p.password)
    case
      bool.exclusive_or(
        get(s, p.min - 1) == p.given,
        get(s, p.max - 1) == p.given,
      )
    {
      True -> acc + 1
      False -> acc
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
