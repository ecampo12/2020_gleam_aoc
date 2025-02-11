import gleam/deque.{type Deque}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile.{read}

fn parse(input: String) -> List(Deque(Int)) {
  string.split(input, "\n\n")
  |> list.map(fn(p) {
    string.split(p, "\n")
    |> list.drop(1)
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(-1) })
    |> deque.from_list
  })
}

fn play_game(p1: Deque(Int), p2: Deque(Int)) -> Deque(Int) {
  case !deque.is_empty(p1) && !deque.is_empty(p2) {
    True -> {
      let assert Ok(#(a, pa)) = deque.pop_front(p1)
      let assert Ok(#(b, pb)) = deque.pop_front(p2)
      case a > b {
        True -> {
          deque.push_back(pa, a)
          |> deque.push_back(b)
          |> play_game(pb)
        }
        False -> {
          deque.push_back(pb, b)
          |> deque.push_back(a)
          |> play_game(pa, _)
        }
      }
    }
    False -> {
      case deque.is_empty(p1) {
        True -> p2
        False -> p1
      }
    }
  }
}

pub fn part1(input: String) -> Int {
  let parsed = parse(input)
  let player1 = list.first(parsed) |> result.unwrap(deque.new())
  let player2 = list.last(parsed) |> result.unwrap(deque.new())

  let winner = play_game(player1, player2) |> deque.to_list
  let len = list.length(winner)
  list.index_fold(winner, 0, fn(acc, x, i) { acc + { x * { len - i } } })
}

fn combat(
  p1: Deque(Int),
  p2: Deque(Int),
  seen: set.Set(#(Deque(Int), Deque(Int))),
) -> #(Int, Deque(Int)) {
  let s = #(p1, p2)
  case set.contains(seen, s) {
    True -> #(1, p1)
    False -> {
      let seen = set.insert(seen, s)
      case !deque.is_empty(p1) && !deque.is_empty(p2) {
        True -> {
          let assert Ok(#(a, pa)) = deque.pop_front(p1)
          let assert Ok(#(b, pb)) = deque.pop_front(p2)
          let winnernum = case a <= deque.length(pa) && b <= deque.length(pb) {
            True -> {
              combat(
                deque.to_list(pa) |> list.take(a) |> deque.from_list,
                deque.to_list(pb) |> list.take(b) |> deque.from_list,
                seen,
              ).0
            }
            False ->
              case a > b {
                True -> 1
                False -> 2
              }
          }
          case winnernum == 1 {
            True -> {
              deque.push_back(pa, a)
              |> deque.push_back(b)
              |> combat(pb, seen)
            }
            False -> {
              deque.push_back(pb, b)
              |> deque.push_back(a)
              |> combat(pa, _, seen)
            }
          }
        }
        False -> {
          case deque.is_empty(p1) {
            True -> #(2, p2)
            False -> #(1, p1)
          }
        }
      }
    }
  }
}

pub fn part2(input: String) -> Int {
  let parsed = parse(input)
  let player1 = list.first(parsed) |> result.unwrap(deque.new())
  let player2 = list.last(parsed) |> result.unwrap(deque.new())

  // apprently I can refernece return values of functions that turn tuples, just like I do with actual tuples.
  let winner = combat(player1, player2, set.new()).1
  let len = deque.length(winner)
  deque.to_list(winner)
  |> list.index_fold(0, fn(acc, x, i) { acc + { x * { len - i } } })
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
