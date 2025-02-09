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

// Apprently theres a limit to how long a regex can be, thank fully regexp follows the PCRE spec which allows for recursive patterns
fn build_rules(rules: Dict(String, String), curr: String, part2: Bool) -> String {
  case part2, curr {
    True, "8" -> build_rules(rules, "42", part2) <> "+"
    True, "11" -> {
      let rule42 = build_rules(rules, "42", part2)
      let rule31 = build_rules(rules, "31", part2)
      "(?P<r42>" <> rule42 <> "(?&r42)?" <> rule31 <> ")"
    }
    _, _ -> {
      case dict.get(rules, curr) {
        Ok(s) -> {
          case s == "a" || s == "b" {
            True -> s
            False ->
              "("
              <> string.split(s, " ")
              |> list.map(fn(x) { build_rules(rules, x, part2) })
              |> string.concat
              <> ")"
          }
        }
        Error(_) -> "|"
      }
    }
  }
}

// Learned that I can use ^ and $ to match the start and end of a string. Makes checking if the whole string matches a regex much easier.
pub fn part1(input: String) -> Int {
  let #(rules, messages) = parse(input)
  let assert Ok(re) =
    regexp.from_string("^" <> build_rules(rules, "0", False) <> "$")
  list.fold(messages, 0, fn(acc, message) {
    case regexp.check(re, message) {
      True -> acc + 1
      False -> acc
    }
  })
}

pub fn part2(input: String) -> Int {
  let #(rules, messages) = parse(input)
  let assert Ok(re) =
    regexp.from_string("^" <> build_rules(rules, "0", True) <> "$")
  list.fold(messages, 0, fn(acc, message) {
    case regexp.check(re, message) {
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
