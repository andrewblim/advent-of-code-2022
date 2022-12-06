defmodule Day06Test do
  use ExUnit.Case
  doctest Day06

  test "day06" do
    assert Day06.problem1("mjqjpqmgbljsphdztnvjfqwrcgsmlb", :io) == 7
    assert Day06.problem1("bvwbjplbgvbhsrlpgdmjqwftvncz", :io) == 5
    assert Day06.problem1("nppdvjthqldpwncqszvftbrmjlhg", :io) == 6
    assert Day06.problem1("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", :io) == 10
    assert Day06.problem1("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", :io) == 11

    assert Day06.problem2("mjqjpqmgbljsphdztnvjfqwrcgsmlb", :io) == 19
    assert Day06.problem2("bvwbjplbgvbhsrlpgdmjqwftvncz", :io) == 23
    assert Day06.problem2("nppdvjthqldpwncqszvftbrmjlhg", :io) == 23
    assert Day06.problem2("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", :io) == 29
    assert Day06.problem2("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", :io) == 26
  end
end
