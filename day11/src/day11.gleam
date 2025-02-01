import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

type Point {
  Point(row: Int, col: Int)
}

fn add(p1: Point, p2: Point) -> Point {
  Point(p1.row + p2.row, p1.col + p2.col)
}

fn scale(p: Point, n: Int) -> Point {
  Point(p.row * n, p.col * n)
}

const neighbors = [
  Point(-1, 0),
  Point(-1, -1),
  Point(-1, 1),
  Point(0, -1),
  Point(0, 1),
  Point(1, -1),
  Point(1, 0),
  Point(1, 1),
]

type Tile {
  Empty
  Occupied
  Floor
}

type Grid {
  Grid(height: Int, g: Dict(Point, Tile), points: List(Point))
}

fn parse(input: String) -> Grid {
  let height = string.split(input, "\n") |> list.length
  let parsed =
    string.split(input, "\n")
    |> list.index_map(fn(row, r) {
      string.to_graphemes(row)
      |> list.index_map(fn(col, c) {
        case col == "L" {
          True -> #(Point(r, c), Empty)
          False -> #(Point(r, c), Floor)
        }
      })
    })
    |> list.flatten
  let points =
    list.map(parsed, fn(x) {
      let #(p, _) = x
      p
    })
  Grid(height, dict.from_list(parsed), points)
}

fn check_neighbors(grid: Grid, curr: Point) -> Int {
  list.fold(neighbors, 0, fn(acc, x) {
    let p = add(curr, x)
    case dict.get(grid.g, p) {
      Ok(Occupied) -> acc + 1
      _ -> acc
    }
  })
}

fn update_seating(
  grid: Grid,
  tolerance: Int,
  check: fn(Grid, Point) -> Int,
) -> Grid {
  let updated =
    list.map(grid.points, fn(x) {
      let count = check(grid, x)
      let assert Ok(tile) = dict.get(grid.g, x)
      let new_t = case tile {
        Empty -> {
          case count == 0 {
            True -> Occupied
            False -> Empty
          }
        }
        Occupied -> {
          case count >= tolerance {
            True -> Empty
            False -> Occupied
          }
        }
        Floor -> Floor
      }
      #(x, new_t)
    })
    |> dict.from_list
  Grid(..grid, g: updated)
}

fn loop(
  grid: Grid,
  input: String,
  tolerance: Int,
  check: fn(Grid, Point) -> Int,
) -> Grid {
  let next = update_seating(grid, tolerance, check)
  case grid == next {
    True -> next
    False -> loop(next, input, tolerance, check)
  }
}

pub fn part1(input: String) -> Int {
  let final = parse(input) |> loop(input, 4, check_neighbors)
  dict.filter(final.g, fn(_k, v) { v == Occupied }) |> dict.size
}

fn check_neighbors2(grid: Grid, curr: Point) -> Int {
  // 3 is arbitrary, its just the smallest scale that will work. gets us a ~.5s speedup
  let scales = list.range(1, grid.height / 3)
  list.fold(neighbors, 0, fn(acc, n) {
    list.fold_until(scales, acc, fn(bcc, s) {
      let p = scale(n, s) |> add(curr)
      case dict.get(grid.g, p) {
        Ok(Occupied) -> list.Stop(bcc + 1)
        Ok(Floor) -> list.Continue(bcc)
        Ok(Empty) | Error(_) -> list.Stop(bcc)
      }
    })
  })
}

pub fn part2(input: String) -> Int {
  let final = parse(input) |> loop(input, 5, check_neighbors2)
  dict.filter(final.g, fn(_k, v) { v == Occupied }) |> dict.size
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
