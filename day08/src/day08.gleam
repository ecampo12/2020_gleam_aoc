import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import glearray.{type Array}
import simplifile.{read}

type InstType {
  ACC
  JMP
  NOP
}

type Instruction {
  Instruction(op: InstType, arg: Int)
}

fn parse(input: String) -> Array(Instruction) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    case string.split(line, " ") {
      [op, n] -> {
        let num = result.unwrap(int.parse(n), 0)
        case op {
          "acc" -> Instruction(ACC, num)
          "jmp" -> Instruction(JMP, num)
          _ -> Instruction(NOP, num)
        }
      }
      _ -> Instruction(NOP, -69)
    }
  })
  |> glearray.from_list
}

fn step(ops: Array(Instruction), accumulator: Int, ip: Int) -> #(Int, Int) {
  case ip < glearray.length(ops) {
    False -> #(accumulator, ip)
    True -> {
      let assert Ok(inst) = glearray.get(ops, ip)
      case inst.op {
        ACC -> #(accumulator + inst.arg, ip + 1)
        JMP -> #(accumulator, ip + inst.arg)
        NOP -> #(accumulator, ip + 1)
      }
    }
  }
}

fn find_loop(
  ops: Array(Instruction),
  accumulator: Int,
  ip: Int,
  seen: Set(Int),
) -> #(Int, Int) {
  case set.contains(seen, ip) {
    True -> #(accumulator, ip)
    False -> {
      let #(acc, i) = step(ops, accumulator, ip)
      find_loop(ops, acc, i, set.insert(seen, ip))
    }
  }
}

pub fn part1(input: String) -> Int {
  let #(acc, _) = parse(input) |> find_loop(0, 0, set.new())
  acc
}

fn fix_program(ops: Array(Instruction), prog_len: Int) -> Int {
  glearray.to_list(ops)
  |> list.index_fold(0, fn(acc, inst, i) {
    let assert Ok(fixed) = case inst.op {
      NOP -> glearray.copy_set(ops, i, Instruction(..inst, op: JMP))
      JMP -> glearray.copy_set(ops, i, Instruction(..inst, op: NOP))
      _ -> Ok(ops)
    }
    let #(accum, ip) = find_loop(fixed, 0, 0, set.new())
    case ip >= prog_len {
      True -> accum
      False -> acc
    }
  })
}

pub fn part2(input: String) -> Int {
  let ops = parse(input)
  let len = glearray.length(ops)
  fix_program(ops, len)
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
