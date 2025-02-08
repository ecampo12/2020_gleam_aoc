import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import simplifile.{read}

fn parse(input: String) -> #(Dict(String, String), List(String)) {
  let rules =
    string.split(input, "\n\n")
    |> list.first
    |> result.unwrap("")
    |> string.replace("\"", "")
    |> string.split("\n")
    |> list.fold(dict.new(), fn(acc, rule) {
      case string.split(rule, ": ") {
        [key, r] -> {
          dict.insert(acc, key, r)
        }
        _ -> acc
      }
    })
  let messages =
    string.split(input, "\n\n")
    |> list.last
    |> result.unwrap("")
    |> string.split("\n")

  #(rules, messages)
}

fn build_rules(rules: Dict(String, String), curr: String, part2: Bool) -> String {
  case dict.get(rules, curr) {
    Ok(s) -> {
      case s == "a" || s == "b" {
        True -> s
        False ->
          {
            "("
            <> string.split(s, " ")
            |> list.map(fn(x) {
              // io.debug(x)
              build_rules(rules, x, part2)
            })
            |> string.concat
          }
          <> ")"
      }
    }
    Error(_) -> "|"
  }
}

pub fn part1(input: String) -> Int {
  let #(rules, messages) = parse(input)
  // build_rules(rules, "0") |> io.debug
  let assert Ok(re) =
    regexp.from_string("(" <> build_rules(rules, "0", False) <> ")")
  list.fold(messages, 0, fn(acc, message) {
    // making sure we match the whole string, not just a substring
    let f =
      regexp.scan(re, message)
      |> list.first
      |> result.unwrap(regexp.Match("", []))
    case f.content == message {
      True -> {
        io.println(message)
        acc + 1
      }
      False -> acc
    }
  })
}

pub fn part2(input: String) -> Int {
  todo
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
