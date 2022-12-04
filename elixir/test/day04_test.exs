defmodule Day04Test do
  use ExUnit.Case
  doctest Day04

  test "day04" do
    input = """
    2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8
    """
    assert Day04.problem1(input, :io) == 2
    assert Day04.problem2(input, :io) == 4
  end
end
