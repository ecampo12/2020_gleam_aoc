import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile.{read}

const modulus = 20_201_227

// A modular exponentiation function, using the square-and-multiply algorithm,
// specifically the right-to-left binary method, which has a time complexity of O(log(exp)).
// https://en.wikipedia.org/wiki/Modular_exponentiation#Right-to-left_binary_method
fn pow_mod(base: Int, exp: Int, m: Int) -> Int {
  case m == 0 {
    True -> 0
    False -> {
      do_pow_mod(base, exp, m, 1)
    }
  }
}

fn do_pow_mod(base: Int, exp: Int, m: Int, acc: Int) -> Int {
  case exp > 0 {
    True -> {
      case exp % 2 == 1 {
        True -> do_pow_mod(base, exp - 1, m, { acc * base } % m)
        False -> do_pow_mod({ base * base } % m, exp / 2, m, acc)
      }
    }
    False -> acc
  }
}

// A baby-step giant-step algorithm for computing discrete logarithms in a finite cyclic group.
// Runs in O(sqrt(p)) time and space.
// https://en.wikipedia.org/wiki/Baby-step_giant-step
fn bs_gs(key: Int) -> Int {
  let n =
    int.to_float(modulus)
    |> float.square_root
    |> result.unwrap(0.0)
    |> float.ceiling
    |> float.truncate
  let t =
    list.range(0, n)
    |> list.map(fn(x) { #(pow_mod(7, x, modulus), x) })
    |> dict.from_list
  let c = pow_mod(7, n * { modulus - 2 }, modulus)
  list.range(0, n)
  |> list.fold_until(0, fn(acc, x) {
    let y = { key * pow_mod(c, x, modulus) } % modulus
    case dict.get(t, y) {
      Error(_) -> list.Continue(acc)
      Ok(idx) -> list.Stop({ x * n } + idx)
    }
  })
}

// Works, but is slower than the baby-step giant-step algorithm.
// Runs ~3.5 seconds compared to ~0.5 seconds for the baby-step giant-step algorithm.
fn brute_force(key: Int) -> Int {
  list.range(0, modulus)
  |> list.fold_until(0, fn(acc, x) {
    case pow_mod(7, x, modulus) == key {
      True -> list.Stop(x)
      False -> list.Continue(acc)
    }
  })
}

// Because erlang, and by extension gleam, has various limitations we can't simply brute-force the solution.
// So we have to use number theory to solve this problem.
// Problems encountered/ solutions:
// - erlang throwing an 'erlang:error(Badarith)' when trying to calculate anything greater than 7^364, which makes sense. It's a really big number.
//    solution: use a modular exponentiation function, gleam doesn't have one, so I wrote one. This works because the problem requires a bunch of 
//              modular arithmetic, so instead of calculating 7^365, we can just calculate 7^365 % 20_201_227, which is much smaller.
// - erlang throwing an undescriptive 'system limit' error when trying to brute force find a number between 1 and 20_201_227 using the power function I wrote for day 13.
//    I managged to get to around 1_200_000 before it errored, so I assume it was some sort of stack overflow.
//    solution: turns out using the modular exponentiation function mentioned in the previous point makes it work. It does a fraction of the calculations, so it makes way less calls.
pub fn part1(input: String) -> Int {
  // int.power(7, 365.0) |> io.debug
  let keys =
    string.split(input, "\n")
    |> list.map(fn(x) { int.parse(x) |> result.unwrap(0) })
  let a = list.first(keys) |> result.unwrap(0)
  let b = list.last(keys) |> result.unwrap(0)

  pow_mod(b, bs_gs(a), 20_201_227)
}

pub fn main() {
  let assert Ok(input) = read("input.txt")
  let part1_ans = part1(input)
  io.print("Part 1: ")
  io.debug(part1_ans)
}
