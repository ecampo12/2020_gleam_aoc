import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/string
import simplifile.{read}

type Grid {
  Grid(height: Int, width: Int, g: Dict(#(Int, Int), Bool))
}

fn parse(ipnut: String) -> Grid {
  let height = string.split(ipnut, "\n") |> list.length
  let assert Ok(line) = string.split(ipnut, "\n") |> list.first
  let width = string.length(line)

  let g =
    string.split(ipnut, "\n")
    |> list.index_map(fn(row, r) {
      string.to_graphemes(row)
      |> list.index_map(fn(col, c) {
        case col == "#" {
          True -> #(#(r, c), True)
          False -> #(#(r, c), False)
        }
      })
    })
    |> list.flatten
    |> dict.from_list
  Grid(height, width, g)
}

fn slide(grid: Grid, curr: #(Int, Int), slope: #(Int, Int), count: Int) -> Int {
  let #(row, col) = curr
  let #(dy, dx) = slope
  let next = #(row + dy, { col + dx } % grid.width)
  case row + 1 == grid.height {
    True -> count
    False ->
      case dict.get(grid.g, next) {
        Ok(True) -> slide(grid, next, slope, count + 1)
        Ok(False) -> slide(grid, next, slope, count)
        Error(_) -> -1
      }
  }
}

pub fn part1(input: String) -> Int {
  parse(input)
  |> slide(#(0, 0), #(1, 3), 0)
}

pub fn part2(input: String) -> Int {
  let grid = parse(input)
  [#(1, 1), #(1, 3), #(1, 5), #(1, 7), #(2, 1)]
  |> list.fold(1, fn(acc, x) { acc * slide(grid, #(0, 0), x, 0) })
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
