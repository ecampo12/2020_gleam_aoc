import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{type Match}
import gleam/string
import simplifile.{read}

fn add_precedence(expression: String) -> String {
  let assert Ok(plus) = regexp.from_string("(\\d+) \\+ (\\d+)")
  let adds = regexp.scan(plus, expression)
  case list.is_empty(adds) {
    True -> expression
    False -> {
      list.fold(adds, expression, fn(acc, x) {
        let rep = case x.submatches {
          [Some(n1), Some(n2)] -> {
            let assert Ok(num1) = int.parse(n1)
            let assert Ok(num2) = int.parse(n2)
            num1 + num2 |> int.to_string
          }
          _ -> x.content
        }
        string.replace(acc, x.content, rep)
      })
      |> add_precedence
    }
  }
}

fn calculate(expression: String, part2: Bool) -> Int {
  let updated = case part2 {
    True -> add_precedence(expression)
    False -> expression
  }
  let assert Ok(re) = regexp.from_string("\\d+")
  let #(val, _) =
    string.split(updated, " ")
    |> list.fold(#(0, "+"), fn(acc, x) {
      let #(num, op) = acc
      case regexp.check(re, x), op {
        True, _ -> {
          let assert Ok(num2) = int.parse(x)
          case op == "+" {
            True -> #(num + num2, op)
            False -> #(num * num2, op)
          }
        }
        False, _ -> #(num, x)
      }
    })
  val
}

fn eval(expression: String, precedence: List(Match), part2: Bool) -> Int {
  let assert Ok(re) = regexp.from_string("\\(([^()]+)\\)")
  let pre = regexp.scan(re, expression)
  case list.is_empty(pre) {
    True -> calculate(expression, part2)
    False -> {
      let update_exp =
        list.fold(precedence, expression, fn(acc, x) {
          let assert Ok(Some(exp)) = x.submatches |> list.first
          calculate(exp, part2)
          |> int.to_string
          |> string.replace(acc, x.content, _)
        })
      regexp.scan(re, update_exp)
      |> eval(update_exp, _, part2)
    }
  }
}

pub fn part1(input: String) -> Int {
  string.split(input, "\n")
  |> list.map(fn(line) { eval(line, [], False) })
  |> int.sum
}

pub fn part2(input: String) -> Int {
  string.split(input, "\n")
  |> list.map(fn(line) { eval(line, [], True) })
  |> int.sum
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
