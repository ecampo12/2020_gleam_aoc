import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import simplifile.{read}

type Point {
  Point(x: Int, y: Int, z: Int, w: Int)
}

fn add(p1: Point, p2: Point) -> Point {
  Point(p1.x + p2.x, p1.y + p2.y, p1.z + p2.z, p1.w + p2.w)
}

fn parse(ipnut: String) -> Set(Point) {
  string.split(ipnut, "\n")
  |> list.index_fold(set.new(), fn(rcc, row, r) {
    string.to_graphemes(row)
    |> list.index_fold(rcc, fn(ccc, col, c) {
      case col == "#" {
        True -> set.insert(ccc, Point(r, c, 0, 0))
        False -> ccc
      }
    })
  })
}

fn min_max(nums: List(Int)) -> #(Int, Int) {
  let sorted = list.sort(nums, int.compare)
  let min = list.first(sorted) |> result.unwrap(-69)
  let max = list.last(sorted) |> result.unwrap(-69)
  #(min, max)
}

fn count_neighbors(cubes: Set(Point), curr: Point, part2: Bool) -> Int {
  list.fold([-1, 0, 1], 0, fn(xcc, dx) {
    list.fold([-1, 0, 1], xcc, fn(ycc, dy) {
      list.fold([-1, 0, 1], ycc, fn(zcc, dz) {
        case part2 {
          True ->
            list.fold([-1, 0, 1], zcc, fn(wcc, dw) {
              case
                { dx != 0 || dy != 0 || dz != 0 || dw != 0 },
                set.contains(cubes, add(curr, Point(dx, dy, dz, dw)))
              {
                True, True -> wcc + 1
                _, _ -> wcc
              }
            })
          False ->
            case
              { dx != 0 || dy != 0 || dz != 0 },
              set.contains(cubes, add(curr, Point(dx, dy, dz, 0)))
            {
              True, True -> zcc + 1
              _, _ -> zcc
            }
        }
      })
    })
  })
}

fn step(cubes: Set(Point), part2: Bool) -> Set(Point) {
  let #(xmin, xmax) = set.map(cubes, fn(n) { n.x }) |> set.to_list |> min_max
  let #(ymin, ymax) = set.map(cubes, fn(n) { n.y }) |> set.to_list |> min_max
  let #(zmin, zmax) = set.map(cubes, fn(n) { n.z }) |> set.to_list |> min_max
  let #(wmin, wmax) = set.map(cubes, fn(n) { n.w }) |> set.to_list |> min_max

  list.range(xmin - 1, xmax + 2)
  |> list.fold(set.new(), fn(xcc, x) {
    list.range(ymin - 1, ymax + 2)
    |> list.fold(xcc, fn(ycc, y) {
      list.range(zmin - 1, zmax + 2)
      |> list.fold(ycc, fn(zcc, z) {
        case part2 {
          True ->
            list.range(wmin - 1, wmax + 2)
            |> list.fold(zcc, fn(wcc, w) {
              let count = count_neighbors(cubes, Point(x, y, z, w), part2)
              case set.contains(cubes, Point(x, y, z, w)), count {
                False, 3 | True, 3 | True, 2 ->
                  set.insert(wcc, Point(x, y, z, w))
                _, _ -> wcc
              }
            })
          False -> {
            let count = count_neighbors(cubes, Point(x, y, z, 0), part2)
            case set.contains(cubes, Point(x, y, z, 0)), count {
              False, 3 | True, 3 | True, 2 -> set.insert(zcc, Point(x, y, z, 0))
              _, _ -> zcc
            }
          }
        }
      })
    })
  })
}

pub fn part1(input: String) -> Int {
  let cubes = parse(input)
  list.range(0, 5)
  |> list.fold(cubes, fn(acc, _x) { step(acc, False) })
  |> set.size
}

pub fn part2(input: String) -> Int {
  let cubes = parse(input)
  list.range(0, 5)
  |> list.fold(cubes, fn(acc, _x) { step(acc, True) })
  |> set.size
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
