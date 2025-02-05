import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import simplifile.{read}

type Data {
  Data(
    // Dict from label to function that checks if a number is in the range
    ranges: Dict(String, fn(Int) -> Bool),
    ticket: List(Int),
    nearby: List(List(Int)),
  )
}

fn parse(input: String) -> Data {
  let assert Ok(re) = regexp.from_string("(\\d+)")
  case string.split(input, "\n\n") {
    [r, ur, n] -> {
      let ranges =
        string.split(r, "\n")
        |> list.fold(dict.new(), fn(acc, x) {
          let label = string.split(x, ": ") |> list.first |> result.unwrap("")
          case
            regexp.scan(re, x)
            |> list.map(fn(match) {
              match.content |> int.parse |> result.unwrap(-1)
            })
          {
            [r1, r2, r3, r4] ->
              dict.insert(acc, label, fn(t) {
                { r1 <= t && t <= r2 } || { r3 <= t && t <= r4 }
              })
            _ -> dict.insert(acc, "none", fn(_a) { False })
          }
        })
      let our_tickets =
        regexp.scan(re, ur)
        |> list.map(fn(match) {
          match.content |> int.parse |> result.unwrap(-1)
        })
      let near_tickets =
        string.split(n, "\n")
        |> list.drop(1)
        |> list.map(fn(line) {
          regexp.scan(re, line)
          |> list.map(fn(match) {
            match.content |> int.parse |> result.unwrap(-1)
          })
        })

      Data(ranges, our_tickets, near_tickets)
    }
    _ -> Data(dict.new(), [], [])
  }
}

pub fn part1(input: String) -> Int {
  let parsed = parse(input)
  list.filter(parsed.nearby |> list.flatten, fn(ticket) {
    !list.any(dict.values(parsed.ranges), fn(r) { r(ticket) })
  })
  |> list.fold(0, fn(acc, x) { acc + x })
}

// rotate a grid 90 degrees clockwise
fn transpose(nums: List(List(Int))) -> List(List(Int)) {
  list.map(nums, fn(x) { list.index_map(x, fn(x, i) { #(x, i) }) })
  |> list.flatten
  |> list.group(fn(x) { x.1 })
  |> dict.values
  |> list.map(fn(x) { x |> list.map(fn(x) { x.0 }) })
}

fn find_order(
  clues: List(List(String)),
  found: Dict(Int, String),
) -> Dict(Int, String) {
  case dict.size(found) == list.length(clues) {
    True -> found
    False -> {
      list.index_fold(clues, found, fn(acc, clue, i) {
        case list.length(clue) == 1 {
          True -> {
            let label = list.first(clue) |> result.unwrap("")
            list.map(clues, fn(a) { list.filter(a, fn(x) { x != label }) })
            |> find_order(dict.insert(acc, i, label))
          }
          False -> acc
        }
      })
    }
  }
}

pub fn part2(input: String) -> Int {
  let parsed = parse(input)
  list.filter(parsed.nearby, fn(ticket) {
    list.all(ticket, fn(t) {
      list.any(dict.values(parsed.ranges), fn(r) { r(t) })
    })
  })
  |> transpose
  |> list.map(fn(ticket) {
    dict.fold(parsed.ranges, [], fn(acc, k, v) {
      case list.all(ticket, fn(t) { v(t) }) {
        True -> list.append(acc, [k])
        False -> acc
      }
    })
  })
  |> find_order(dict.new())
  |> dict.values
  |> list.zip(parsed.ticket)
  |> list.filter(fn(x) { string.starts_with(x.0, "departure") })
  |> list.fold(1, fn(acc, x) { acc * x.1 })
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
