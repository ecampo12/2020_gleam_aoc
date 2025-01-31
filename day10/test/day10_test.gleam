import day10.{part1, part2}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn part1_small_example_test() {
  "16
10
15
5
1
11
7
19
6
12
4"
  |> part1
  |> should.equal(35)
}

pub fn part1_large_example_test() {
  "28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3"
  |> part1
  |> should.equal(220)
}

pub fn part2_small_example_test() {
  "16
10
15
5
1
11
7
19
6
12
4"
  |> part2
  |> should.equal(8)
}

pub fn part2_large_example_test() {
  "28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3"
  |> part2
  |> should.equal(19_208)
}
