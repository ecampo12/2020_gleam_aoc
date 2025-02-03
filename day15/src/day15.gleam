import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile.{read}

fn parse(input: String) -> Dict(Int, List(Int)) {
  let parsed =
    string.split(input, ",")
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(-1) })

  list.index_map(parsed, fn(x, i) { #(x, [i + 1]) }) |> dict.from_list
}

pub fn part1(input: String) -> Int {
  let p = parse(input)
  let res =
    list.range(dict.size(p) + 1, 2020)
    |> list.fold(#(parse(input), 0), fn(acc, t) {
      let #(spoken, last) = acc

      let turns = dict.get(spoken, last) |> result.unwrap([])
      let next = case list.length(turns) >= 2 {
        True -> {
          let l = list.drop(turns, list.length(turns) - 2)
          let a = list.first(l) |> result.unwrap(-1)
          let b = list.last(l) |> result.unwrap(-1)
          b - a
        }
        False -> 0
      }

      let update =
        dict.upsert(spoken, next, fn(x) {
          case x {
            Some(i) -> list.append(i, [t])
            None -> [t]
          }
        })
      #(update, next)
    })
  res.1
}

// This is the same as part1, but with a larger range. I checked the subreddit and there doesn't seem to be faster mathematically way to solve this.
// I am sure is some repeated pattern that can be used to solve this, but I didn't find it. So I just brute forced it.
pub fn part2(input: String) -> Int {
  let p = parse(input)
  let res =
    list.range(dict.size(p) + 1, 30_000_000)
    |> list.fold(#(p, 0), fn(acc, t) {
      case t {
        _ if t % 1_000_000 == 0 -> io.println(int.to_string(t))
        _ -> io.print("")
      }
      let #(spoken, last) = acc

      let turns = dict.get(spoken, last) |> result.unwrap([])
      let next = case list.length(turns) == 2 {
        True -> {
          let a = list.first(turns) |> result.unwrap(-1)
          let b = list.last(turns) |> result.unwrap(-1)
          b - a
        }
        False -> 0
      }

      let update =
        dict.upsert(spoken, next, fn(x) {
          case x {
            Some(i) -> {
              // Turns out only keeping the last two will speed up the program
              case list.length(i) >= 2 {
                True -> list.drop(i, list.length(i) - 1)
                False -> i
              }
              |> list.append([t])
            }
            None -> [t]
          }
        })
      #(update, next)
    })
  res.1
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
