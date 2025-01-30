import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/regexp
import gleam/result.{unwrap}
import gleam/set.{type Set}
import gleam/string
import simplifile.{read}

type InnerBags =
  Dict(String, Set(String))

type Contains =
  Dict(String, List(#(Int, String)))

pub fn parse(input: String) -> #(InnerBags, Contains) {
  let assert Ok(color_re) = regexp.from_string("(.+?) bags contain")
  let assert Ok(inner_colors_re) = regexp.from_string("(\\d+) (.+?) bags?[,.]")

  string.split(input, "\n")
  |> list.fold(#(dict.new(), dict.new()), fn(acc, line) {
    let assert Ok(match) = regexp.scan(color_re, line) |> list.first
    let assert Ok(Some(color)) = match.submatches |> list.first

    regexp.scan(inner_colors_re, line)
    |> list.fold(acc, fn(bcc, inner) {
      let #(contained_in, contains) = bcc
      case inner.submatches {
        [Some(n), Some(c)] -> {
          let num = unwrap(int.parse(n), 0)
          let a =
            dict.upsert(contained_in, c, fn(x) {
              case x {
                Some(v) -> set.insert(v, color)
                None -> set.new() |> set.insert(color)
              }
            })
          let b =
            dict.upsert(contains, color, fn(x) {
              case x {
                Some(v) -> list.append(v, [#(num, c)])
                None -> [#(num, c)]
              }
            })
          #(a, b)
        }
        _ -> acc
      }
    })
  })
}

fn outter_bags(
  rules: InnerBags,
  color: String,
  options: Set(String),
) -> Set(String) {
  unwrap(dict.get(rules, color), set.new())
  |> set.fold(options, fn(acc, x) { outter_bags(rules, x, set.insert(acc, x)) })
}

pub fn part1(input: InnerBags) -> Int {
  outter_bags(input, "shiny gold", set.new()) |> set.size
}

fn total_bags(rules: Contains, color: String) -> Int {
  unwrap(dict.get(rules, color), [])
  |> list.fold(0, fn(acc, x) {
    let #(bags, c) = x
    acc + bags + { bags * total_bags(rules, c) }
  })
}

pub fn part2(input: Contains) -> Int {
  total_bags(input, "shiny gold")
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let #(rules1, rules2) = parse(input)
  let part1_ans = part1(rules1)
  io.print("Part 1: ")
  io.debug(part1_ans)
  let part2_ans = part2(rules2)
  io.print("Part 2: ")
  io.debug(part2_ans)
}
