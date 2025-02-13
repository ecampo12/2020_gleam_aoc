import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

// Originally wrote up a whole linked litst implementation for this, but it was too slo for part 2.
// So I rewrote it using a dict, which is still slow, but at least it's fast enough to solve the puzzle in 2 minutes.
// I think it's slow because, like everything in gleam, dicts are immutable, so every update is a copy.
fn build_nodes(input: String, extra: List(Int)) -> #(Int, dict.Dict(Int, Int)) {
  let x =
    string.to_graphemes(input)
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
    |> list.append(extra)
  let first = list.first(x) |> result.unwrap(0)
  let nodes =
    list.zip(x, list.append(list.drop(x, 1), [first]))
    |> list.fold([], fn(acc, x) {
      let #(a, b) = x
      [#(a, b), ..acc]
    })
    |> dict.from_list
  #(first, nodes)
}

fn find_destination(
  cup: Int,
  cups: dict.Dict(Int, Int),
  removed: List(Int),
  size: Int,
) -> Int {
  case dict.get(cups, cup), cup {
    _, 0 -> find_destination(size, cups, removed, size)
    Ok(_), _ -> {
      case list.contains(removed, cup) {
        True -> find_destination(cup - 1, cups, removed, size)
        False -> cup
      }
    }
    Error(_), _ -> find_destination(cup - 1, cups, removed, size)
  }
}

// Instead of moving the cups around, like with my linked list implementation, we just update what each cup points to.
fn crab_cups(
  front: Int,
  node_dict: dict.Dict(Int, Int),
  size: Int,
) -> #(Int, dict.Dict(Int, Int)) {
  let x = [dict.get(node_dict, front) |> result.unwrap(0)]
  let y =
    list.append(x, [
      dict.get(node_dict, list.first(x) |> result.unwrap(0))
      |> result.unwrap(0),
    ])
  let z =
    list.append(y, [
      dict.get(node_dict, list.last(y) |> result.unwrap(0))
      |> result.unwrap(0),
    ])

  let dest = find_destination(front - 1, node_dict, z, size)
  let last = list.last(z) |> result.unwrap(0)
  let a =
    dict.insert(node_dict, front, dict.get(node_dict, last) |> result.unwrap(0))
  let b = dict.insert(a, last, dict.get(a, dest) |> result.unwrap(0))
  let c = dict.insert(b, dest, list.first(z) |> result.unwrap(0))

  dict.get(c, front) |> result.unwrap(0)
  #(dict.get(c, front) |> result.unwrap(0), c)
}

fn dict_to_string(nodes: dict.Dict(Int, Int), key: Int, str: String) -> String {
  case dict.get(nodes, key) |> result.unwrap(1) {
    1 -> str
    x -> dict_to_string(nodes, x, str <> int.to_string(x))
  }
}

pub fn part1(input: String) -> String {
  let #(first, nodes) = build_nodes(input, [])
  let #(_, c) =
    list.range(1, 100)
    |> list.fold(#(first, nodes), fn(acc, _x) {
      let #(f, updates) = crab_cups(acc.0, acc.1, 9)
      #(f, updates)
    })

  dict_to_string(c, 1, "")
}

// takes about 1.5 minutes to run on my PC.
pub fn part2(input: String) -> String {
  let extended = list.range(10, 1_000_000)
  let #(first, nodes) = build_nodes(input, extended)
  let #(_, c) =
    list.range(1, 10_000_000)
    |> list.fold(#(first, nodes), fn(acc, turn) {
      // here to make it easier to see progress
      case turn % 500_000 == 0 {
        True -> io.println(int.to_string(turn))
        _ -> io.print("")
      }
      let #(f, updates) = crab_cups(acc.0, acc.1, 1_000_000)
      #(f, updates)
    })
  let a = dict.get(c, 1) |> result.unwrap(0)
  let b = dict.get(c, a) |> result.unwrap(0)
  int.to_string(a * b)
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
