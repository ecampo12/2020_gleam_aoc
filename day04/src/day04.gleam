import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{type Match}
import gleam/string
import simplifile.{read}

fn is_valid(passport: String) -> Bool {
  let assert Ok(re) = regexp.from_string("byr|iyr|eyr|hgt|hcl|ecl|pid")
  regexp.scan(re, passport) |> list.length == 7
}

pub fn part1(input: String) -> Int {
  string.split(input, "\n\n")
  |> list.filter(is_valid)
  |> list.length
}

fn get_num(result: List(Match)) -> Int {
  case result {
    [match] ->
      case match.submatches {
        [Some(x)] -> {
          let assert Ok(n) = int.parse(x)
          n
        }
        _ -> -1
      }
    _ -> -1
  }
}

fn validate_range(input: String, field: String, start: Int, end: Int) -> Bool {
  let assert Ok(re) = regexp.from_string(field <> ":(\\d+)")
  let year = get_num(regexp.scan(re, input))
  case get_num(regexp.scan(re, input)) != -1 {
    True -> start <= year && year <= end
    False -> False
  }
}

fn validate_height(input: String) -> Bool {
  let assert Ok(re) = regexp.from_string("hgt:(\\d+(in|cm))")

  regexp.scan(re, input)
  case regexp.scan(re, input) {
    [match] ->
      case match.submatches {
        [Some(_), Some(unit)] ->
          case unit == "cm" {
            True -> {
              validate_range(input, "hgt", 150, 193)
            }
            False -> {
              validate_range(input, "hgt", 59, 76)
            }
          }
        _ -> False
      }
    _ -> False
  }
}

fn validate_rest(input: String) -> Bool {
  let assert Ok(hair_color) = regexp.from_string("hcl:(#[0-9a-f]{6})")
  let assert Ok(eye_color) =
    regexp.from_string("ecl:(amb|blu|brn|gry|grn|hzl|oth)")
  let assert Ok(pid) = regexp.from_string("pid:(\\d+)")
  let pid_valid = case regexp.scan(pid, input) {
    [match] -> string.length(match.content) == 13
    _ -> False
  }
  regexp.check(hair_color, input) && regexp.check(eye_color, input) && pid_valid
}

pub fn part2(input: String) -> Int {
  string.split(input, "\n\n")
  |> list.filter(is_valid)
  |> list.filter(fn(x) {
    validate_range(x, "byr", 1920, 2002)
    && validate_range(x, "iyr", 2010, 2020)
    && validate_range(x, "eyr", 2020, 2030)
    && validate_height(x)
    && validate_rest(x)
  })
  |> list.length
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
