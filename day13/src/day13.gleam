import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

fn parse(input: String) -> #(Int, List(Int)) {
  case string.split(input, "\n") {
    [t, i] -> {
      let time = int.parse(t) |> result.unwrap(-1)
      let ids =
        string.split(i, ",")
        |> list.map(fn(x) { int.parse(x) |> result.unwrap(-1) })
      #(time, ids)
    }
    _ -> #(-1, [-69])
  }
}

pub fn part1(input: String) -> Int {
  let #(time, ids) = parse(input)
  let res =
    list.filter(ids, fn(x) { x != -1 })
    |> list.map(fn(x) { #({ time / x } * x + x, x) })
    |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
    |> list.first
    |> result.unwrap(#(-1, -2))
  { res.0 - time } * res.1
}

// kept getting a 'erlang:error(Badarith)' error when trying to use the built-in power function
fn power(n: Int, e: Int) -> Int {
  case e == 0, e < 0 {
    True, _ -> 1
    False, False -> n * power(n, e - 1)
    False, True -> 1.0 /. { power(n, -e) |> int.to_float } |> float.truncate
  }
}

fn chineese_remainer_theorem(nums: List(#(Int, Int))) -> Int {
  let m = list.fold(nums, 1, fn(acc, x) { acc * x.0 })
  list.fold(nums, 0, fn(acc, x) {
    let b = m / x.0
    // used the modulo function since the base number can be negative
    int.modulo(acc + { x.1 * b * { power(b, x.0 - 2) % x.0 } }, m)
    |> result.unwrap(-1)
  })
}

pub fn part2(input: String) -> Int {
  let #(_, ids) = parse(input)

  list.index_map(ids, fn(x, i) { #(x, i) })
  |> list.filter(fn(x) { x.0 != -1 })
  |> list.map(fn(x) { #(x.0, x.0 - x.1) })
  |> chineese_remainer_theorem
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
