import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import simplifile.{read}

type Memory {
  Memory(mask: String, mem: Dict(String, Int))
}

fn apply_mask(mask: String, val: String) -> String {
  list.zip(string.to_graphemes(val), string.to_graphemes(mask))
  |> list.fold("", fn(acc, pair) {
    case pair {
      #("1", "X") -> acc <> "1"
      #("0", "X") -> acc <> "0"
      #("0", "1") -> acc <> "1"
      #("1", "0") -> acc <> "0"
      #("0", "0") -> acc <> "0"
      #("1", "1") -> acc <> "1"
      _ -> acc
    }
  })
}

pub fn part1(input: String) -> Int {
  let assert Ok(num) = regexp.from_string("(\\d+)")
  let res =
    string.split(input, "\n")
    |> list.fold(Memory("", dict.new()), fn(acc, line) {
      case string.split(line, " = ") {
        [label, mask] if label == "mask" -> Memory(..acc, mask: mask)
        _ -> {
          case regexp.scan(num, line) |> list.map(fn(x) { x.content }) {
            [address, val] -> {
              let masked_val =
                int.parse(val)
                |> result.unwrap(0)
                |> int.to_base2
                |> string.pad_start(36, "0")
                |> apply_mask(acc.mask, _)
                |> int.base_parse(2)
                |> result.unwrap(0)
              Memory(..acc, mem: dict.insert(acc.mem, address, masked_val))
            }
            _ -> acc
          }
        }
      }
    })
  dict.fold(res.mem, 0, fn(acc, _k, v) { acc + v })
}

fn apply_mask2(mask: String, val: String) -> String {
  list.zip(string.to_graphemes(val), string.to_graphemes(mask))
  |> list.fold("", fn(acc, pair) {
    case pair {
      #("1", "X") -> acc <> "X"
      #("0", "X") -> acc <> "X"
      #("0", "1") -> acc <> "1"
      #("1", "0") -> acc <> "1"
      #("0", "0") -> acc <> "0"
      #("1", "1") -> acc <> "1"
      _ -> acc
    }
  })
}

fn generate_addresses(address: List(String), curr: String) -> List(String) {
  case address {
    [x, ..rest] if x == "X" -> {
      [
        generate_addresses(rest, "0" <> curr),
        generate_addresses(rest, "1" <> curr),
      ]
      |> list.flatten
    }
    [x, ..rest] -> generate_addresses(rest, x <> curr)
    [] -> [curr]
  }
}

pub fn part2(input: String) -> Int {
  let assert Ok(num) = regexp.from_string("(\\d+)")
  let res =
    string.split(input, "\n")
    |> list.fold(Memory("", dict.new()), fn(acc, line) {
      case string.split(line, " = ") {
        [label, mask] if label == "mask" -> Memory(..acc, mask: mask)
        _ -> {
          case regexp.scan(num, line) |> list.map(fn(x) { x.content }) {
            [address, v] -> {
              let val = int.parse(v) |> result.unwrap(0)
              let mem =
                int.parse(address)
                |> result.unwrap(0)
                |> int.to_base2
                |> string.pad_start(36, "0")
                |> apply_mask2(acc.mask, _)
                |> string.to_graphemes
                |> generate_addresses("")
                |> list.fold(acc.mem, fn(mcc, x) { dict.insert(mcc, x, val) })
              Memory(..acc, mem: mem)
            }
            _ -> acc
          }
        }
      }
    })
  dict.fold(res.mem, 0, fn(acc, _k, v) { acc + v })
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
