import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile.{read}

type Point {
  Point(x: Int, y: Int)
}

fn add(p1: Point, p2: Point) {
  Point(p1.x + p2.x, p1.y + p2.y)
}

fn get_direction(dir: String) -> Point {
  case dir {
    "e" -> Point(1, 0)
    "se" -> Point(0, -1)
    "sw" -> Point(-1, -1)
    "w" -> Point(-1, 0)
    "nw" -> Point(0, 1)
    "ne" -> Point(1, 1)
    _ -> Point(-69, -69)
  }
}

pub fn part1(input: String) -> Int {
  string.split(input, "\n")
  |> list.fold(dict.new(), fn(acc, x) {
    let assert Ok(re) = regexp.from_string("e|se|sw|w|nw|ne")
    regexp.scan(re, x)
    |> list.map(fn(x) { x.content })
    |> list.fold(Point(0, 0), fn(acc, x) { add(acc, get_direction(x)) })
    |> dict.upsert(acc, _, fn(k) {
      case k {
        Some(v) -> v + 1
        None -> 1
      }
    })
  })
  |> dict.fold(0, fn(acc, _k, v) {
    case int.is_odd(v) {
      True -> acc + 1
      False -> acc
    }
  })
}

const adj = [
  Point(1, 0),
  Point(0, -1),
  Point(-1, -1),
  Point(-1, 0),
  Point(0, 1),
  Point(1, 1),
]

fn steps(flips: Dict(Point, Int)) -> Dict(Point, Int) {
  let adj_black =
    dict.fold(flips, dict.new(), fn(acc, k, v) {
      case int.is_even(v) {
        True -> acc
        False -> {
          list.fold(adj, acc, fn(bcc, x) {
            dict.upsert(bcc, add(k, x), fn(v) {
              case v {
                Some(v) -> v + 1
                None -> 1
              }
            })
          })
        }
      }
    })

  dict.fold(flips, dict.new(), fn(acc, k, v) {
    case int.is_odd(v) {
      True -> {
        case
          !{
            dict.get(adj_black, k)
            |> result.unwrap(0)
            |> list.contains([1, 2], _)
          }
        {
          True -> acc
          False -> dict.insert(acc, k, 1)
        }
      }
      False -> acc
    }
  })
  |> dict.fold(adj_black, _, fn(acc, k, v) {
    case v == 2 && int.is_even(dict.get(flips, k) |> result.unwrap(0)) {
      True -> dict.insert(acc, k, 1)
      False -> acc
    }
  })
}

pub fn part2(input: String) -> Int {
  let flips =
    string.split(input, "\n")
    |> list.fold(dict.new(), fn(acc, x) {
      let assert Ok(re) = regexp.from_string("e|se|sw|w|nw|ne")
      regexp.scan(re, x)
      |> list.map(fn(x) { x.content })
      |> list.fold(Point(0, 0), fn(acc, x) { add(acc, get_direction(x)) })
      |> dict.upsert(acc, _, fn(k) {
        case k {
          Some(v) -> v + 1
          None -> 1
        }
      })
    })
  list.range(1, 100)
  |> list.fold(flips, fn(acc, _x) { steps(acc) })
  |> dict.fold(0, fn(acc, _k, v) {
    case int.is_odd(v) {
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
