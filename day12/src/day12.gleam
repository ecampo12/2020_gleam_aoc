import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

type Instruction {
  Instruction(action: Actions, val: Int)
}

type Actions {
  East
  South
  West
  North
  Left
  Right
  Forward
}

const directions = [#(0, East), #(1, South), #(2, West), #(3, North)]

const directions_idx = [#(East, 0), #(South, 1), #(West, 2), #(North, 3)]

type Point {
  Point(x: Int, y: Int)
}

fn add(p1: Point, p2: Point) -> Point {
  Point(p1.x + p2.x, p1.y + p2.y)
}

type Ship {
  Ship(dir: Actions, pos: Point)
}

fn parse(input: String) -> List(Instruction) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let s = string.to_graphemes(line)
    let action = case list.first(s) |> result.unwrap("Z") {
      "N" -> North
      "S" -> South
      "E" -> East
      "W" -> West
      "L" -> Left
      "R" -> Right
      "F" -> Forward
      _ -> East
    }
    let value =
      list.rest(s)
      |> result.unwrap([])
      |> string.concat
      |> int.parse
      |> result.unwrap(-69)
    Instruction(action, value)
  })
}

fn rotate(inst: Instruction, ship: Ship) -> Actions {
  let assert Ok(index) = directions_idx |> list.key_find(ship.dir)
  let rot = inst.val / 90
  case inst.action {
    Right -> {
      let assert Ok(next_index) = int.modulo(index + rot, 4)
      let assert Ok(next) = directions |> list.key_find(next_index)
      next
    }
    Left -> {
      let assert Ok(next_index) = int.modulo(index - rot, 4)
      let assert Ok(next) = directions |> list.key_find(next_index)
      next
    }
    _ -> inst.action
  }
}

fn forward(inst: Instruction, ship: Ship) -> Point {
  case ship.dir {
    North -> add(Point(0, inst.val), ship.pos)
    South -> add(Point(0, -inst.val), ship.pos)
    East -> add(Point(inst.val, 0), ship.pos)
    West -> add(Point(-inst.val, 0), ship.pos)
    _ -> Point(-69, -69)
  }
}

pub fn part1(input: String) -> Int {
  let destination =
    parse(input)
    |> list.fold(Ship(East, Point(0, 0)), fn(ship, inst) {
      case inst.action {
        North -> Ship(..ship, pos: add(Point(0, inst.val), ship.pos))
        South -> Ship(..ship, pos: add(Point(0, -inst.val), ship.pos))
        East -> Ship(..ship, pos: add(Point(inst.val, 0), ship.pos))
        West -> Ship(..ship, pos: add(Point(-inst.val, 0), ship.pos))
        Left | Right -> Ship(..ship, dir: rotate(inst, ship))
        Forward -> Ship(..ship, pos: forward(inst, ship))
      }
    })
  int.absolute_value(destination.pos.x) + int.absolute_value(destination.pos.y)
}

pub fn part2(input: String) -> Int {
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
