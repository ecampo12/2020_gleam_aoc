import gleam/int
import gleam/io
import gleam/list
import gleam/regexp.{type Regexp, check}
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

fn build_str(tag: String, start: Int, end: Int) -> String {
  list.range(start, end)
  |> list.fold(tag <> ":(", fn(acc, x) {
    case x == end {
      True -> acc <> int.to_string(x) <> ")"
      False -> acc <> int.to_string(x) <> "|"
    }
  })
}

// First attempt parsed feilds that had numbers to check if they were in range.
// This generates along regex for feilds that a range. It is not any faster
// than the other implementation, but it has less parsing and looks nicer.
fn generate_regexp(tag: String, start: Int, end: Int) -> Regexp {
  let assert Ok(re) = build_str(tag, start, end) |> regexp.from_string
  re
}

fn height_regexp() -> Regexp {
  let cm = build_str("hgt", 150, 193) <> "cm"
  let in = build_str("hgt", 59, 76) <> "in"
  let assert Ok(re) = regexp.from_string(cm <> "|" <> in)
  re
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
  check(hair_color, input) && check(eye_color, input) && pid_valid
}

pub fn part2(input: String) -> Int {
  let byr = generate_regexp("byr", 1920, 2002)
  let iyr = generate_regexp("iyr", 2010, 2020)
  let eyr = generate_regexp("eyr", 2020, 2030)
  let hgt = height_regexp()
  string.split(input, "\n\n")
  |> list.filter(fn(x) {
    check(byr, x)
    && check(iyr, x)
    && check(eyr, x)
    && check(hgt, x)
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
