import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/set
import gleam/string
import simplifile.{read}

fn parse(input: String) -> List(#(List(String), List(String))) {
  let assert Ok(re) = regexp.from_string("(.*) \\(contains (.*)\\)")
  string.split(input, "\n")
  |> list.fold([], fn(acc, line) {
    let assert Ok(match) = regexp.scan(re, line) |> list.first
    case match.submatches {
      [Some(ingredients), Some(allergens)] -> {
        list.append(acc, [
          #(string.split(ingredients, " "), string.split(allergens, ", ")),
        ])
      }
      _ -> acc
    }
  })
}

fn possible_allergens(
  foods: List(#(List(String), List(String))),
) -> Dict(String, set.Set(String)) {
  let all_ingredients =
    list.map(foods, fn(x) { x.0 }) |> list.flatten |> set.from_list
  let all_allergens =
    list.map(foods, fn(x) { x.1 }) |> list.flatten |> set.from_list
  let could_be =
    set.fold(all_ingredients, dict.new(), fn(acc, x) {
      dict.insert(acc, x, all_allergens)
    })

  list.fold(foods, could_be, fn(acc, x) {
    let #(ingredients, allergens) = x
    list.fold(allergens, acc, fn(bcc, a) {
      set.fold(all_ingredients, bcc, fn(ccc, i) {
        case list.contains(ingredients, i) {
          True -> ccc
          False -> {
            let current = dict.get(ccc, i) |> result.unwrap(set.new())
            dict.insert(ccc, i, set.delete(current, a))
          }
        }
      })
    })
  })
}

pub fn part1(input: String) -> Int {
  let foods = parse(input)
  let count =
    list.map(foods, fn(x) { x.0 }) |> list.flatten |> list.group(fn(x) { x })

  possible_allergens(foods)
  |> dict.filter(fn(_, v) { set.size(v) == 0 })
  |> dict.keys
  |> list.fold(0, fn(acc, x) {
    acc + { dict.get(count, x) |> result.unwrap([]) |> list.length }
  })
}

pub fn part2(input: String) -> String {
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
